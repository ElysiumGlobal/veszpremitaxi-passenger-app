<?php

declare(strict_types=1);

/*
 * Veszpremi Taxi - Firebase utasfiok backend patch
 * Version: 2026-07-30-firebase-passenger-v1
 *
 * Funkcio:
 * - Firebase ID token szerveroldali ellenorzese.
 * - Google vagy ellenorzott e-mailes Firebase felhasznalo azonnali letrehozasa/osszekotese a Laravel users tablaban.
 * - A meglevo Laravel belepteto logika ujrahasznositasa, igy ugyanazt az API tokent kapja az app.
 * - Telefonszam kotelezo befejezese kulon vedett vegponton.
 *
 * Feltoltes: Laravel public/ mappa.
 * Eloszor CHECK, utana INSTALL. Automatikus fajl-backup keszul.
 */

header('X-Robots-Tag: noindex, nofollow', true);
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Content-Type: text/html; charset=UTF-8');

const VTAXI_FIREBASE_PATCH_VERSION = '2026-07-30-firebase-passenger-v1';
const VTAXI_FIREBASE_PATCH_KEY = 'd0cb3d9b7c334417b2f4c6f07308fd2a';
const VTAXI_FIREBASE_CONTROLLER_MARKER = 'VTAXI_FIREBASE_PASSENGER_20260730';
const VTAXI_FIREBASE_ROUTE_MARKER = 'VTAXI_FIREBASE_PASSENGER_ROUTES_20260730';
const VTAXI_FIREBASE_PROJECT_ID = 'vtaxi-503221';

function vtaxi_h(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
}

function vtaxi_json(mixed $value): string
{
    return (string) json_encode(
        $value,
        JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
}

function vtaxi_find_root(): string
{
    $candidates = [
        realpath(__DIR__ . '/..'),
        realpath(__DIR__),
        realpath(__DIR__ . '/../veszpremitaxi-api'),
    ];

    foreach ($candidates as $candidate) {
        if (!is_string($candidate) || $candidate === '') {
            continue;
        }

        if (
            is_file($candidate . '/artisan')
            && is_file($candidate . '/bootstrap/app.php')
            && is_dir($candidate . '/app/Http/Controllers/Api')
            && is_file($candidate . '/routes/api.php')
        ) {
            return $candidate;
        }
    }

    throw new RuntimeException(
        'Nem talaltam a Laravel projekt gyokeret. A fajlt a Laravel public/ mappajaba toltsd fel.'
    );
}

function vtaxi_bootstrap(string $root): void
{
    static $booted = false;
    if ($booted) {
        return;
    }

    $autoload = $root . '/vendor/autoload.php';
    $bootstrap = $root . '/bootstrap/app.php';

    if (!is_file($autoload) || !is_file($bootstrap)) {
        throw new RuntimeException('A Laravel bootstrap fajlok nem talalhatok.');
    }

    require_once $autoload;
    $app = require $bootstrap;
    $app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
    $booted = true;
}

function vtaxi_controller_path(string $root): string
{
    return $root . '/app/Http/Controllers/Api/VTaxiFirebaseAuthController.php';
}

function vtaxi_routes_path(string $root): string
{
    return $root . '/routes/api.php';
}

function vtaxi_controller_source(): string
{
    return <<<'PHP_CONTROLLER'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Route as RoutingRoute;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class VTaxiFirebaseAuthController extends Controller
{
    private const FIREBASE_PROJECT_ID = 'vtaxi-503221';

    public function login(Request $request): JsonResponse
    {
        // VTAXI_FIREBASE_PASSENGER_20260730
        $data = $request->validate([
            'firebase_id_token' => ['required', 'string', 'min:100'],
            'auth_provider' => ['required', 'string', 'in:email,google'],
            'device_token' => ['nullable', 'string', 'max:2048'],
            'password' => ['nullable', 'string', 'max:255'],
            'name' => ['nullable', 'string', 'max:255'],
            'profile_image' => ['nullable', 'string', 'max:2048'],
            'id' => ['nullable', 'string', 'max:255'],
        ]);

        try {
            $firebase = $this->verifyFirebaseIdToken($data['firebase_id_token']);
            $uid = trim((string) ($firebase['localId'] ?? ''));
            $email = strtolower(trim((string) ($firebase['email'] ?? '')));
            $emailVerified = filter_var($firebase['emailVerified'] ?? false, FILTER_VALIDATE_BOOLEAN);

            if ($uid === '' || $email === '') {
                return response()->json([
                    'success' => false,
                    'message' => 'A Firebase fiokbol hianyzik az egyedi azonosito vagy az e-mail-cim.',
                    'code' => 'firebase_identity_incomplete',
                ], 422);
            }

            if (!$emailVerified) {
                return response()->json([
                    'success' => false,
                    'message' => 'Eloszor erositsd meg az e-mail-cimedet a kikuldott levelben.',
                    'code' => 'email_not_verified',
                ], 403);
            }

            $provider = (string) $data['auth_provider'];
            $providerIds = collect($firebase['providerUserInfo'] ?? [])
                ->pluck('providerId')
                ->filter()
                ->map(static fn ($value) => (string) $value)
                ->values()
                ->all();

            if ($provider === 'google' && !in_array('google.com', $providerIds, true)) {
                return response()->json([
                    'success' => false,
                    'message' => 'A Firebase token nem Google-belepessel keszult.',
                    'code' => 'firebase_provider_mismatch',
                ], 403);
            }


            if ($provider === 'email' && trim((string) ($data['password'] ?? '')) === '') {
                return response()->json([
                    'success' => false,
                    'message' => 'Az e-mailes belepeshez jelszo szukseges.',
                    'code' => 'password_required',
                ], 422);
            }

            [$user, $created] = DB::transaction(function () use ($uid, $email, $provider, $firebase, $data) {
                $userClass = $this->userClass();

                $byUid = Schema::hasColumn('users', 'firebase_uid')
                    ? $userClass::query()->where('firebase_uid', $uid)->where('role_id', 3)->lockForUpdate()->first()
                    : null;

                $byEmail = $userClass::query()
                    ->whereRaw('LOWER(email) = ?', [$email])
                    ->where('role_id', 3)
                    ->lockForUpdate()
                    ->first();

                if ($byUid && $byEmail && (int) $byUid->id !== (int) $byEmail->id) {
                    throw new \RuntimeException('A Firebase UID es az e-mail-cim ket kulon utasfiokhoz tartozik.');
                }

                $user = $byUid ?: $byEmail;
                $created = false;

                if (!$user) {
                    $user = new $userClass();
                    $created = true;
                }

                $displayName = trim((string) (
                    $firebase['displayName']
                    ?? $data['name']
                    ?? ''
                ));
                if ($displayName === '') {
                    $displayName = trim((string) strstr($email, '@', true));
                }
                if ($displayName === '') {
                    $displayName = 'Veszpremi Taxi utas';
                }

                $photo = trim((string) (
                    $firebase['photoUrl']
                    ?? $data['profile_image']
                    ?? ''
                ));

                $values = [
                    'name' => $displayName,
                    'email' => $email,
                    'role_id' => 3,
                    'status' => 'active',
                    'gender' => trim((string) ($user->gender ?? '')) === '' ? 'other' : $user->gender,
                    'login_device' => $provider,
                    'is_verified' => 1,
                    'verified_at' => now(),
                    'email_verified_at' => now(),
                    'country_code' => '+36',
                    'is_register' => trim((string) ($user->phone ?? '')) === '' ? 0 : 1,
                    'step_0' => 1,
                    'step_1' => trim((string) ($user->phone ?? '')) === '' ? 0 : 1,
                    'step_2' => trim((string) ($user->phone ?? '')) === '' ? 0 : 1,
                    'step_3' => trim((string) ($user->phone ?? '')) === '' ? 0 : 1,
                    'firebase_uid' => $uid,
                    'firebase_provider' => $provider,
                    'firebase_email_verified_at' => now(),
                    'device_token' => trim((string) ($data['device_token'] ?? '')),
                ];

                if ($photo !== '') {
                    $values['profile_photo'] = $photo;
                }

                if ($created && Schema::hasColumn('users', 'phone')) {
                    $values['phone'] = null;
                }

                if ($provider === 'email') {
                    $values['password'] = Hash::make((string) $data['password']);
                } elseif ($created || trim((string) ($user->password ?? '')) === '') {
                    $values['password'] = Hash::make(Str::random(64));
                }

                if (Schema::hasColumn('users', 'referral_code') && trim((string) ($user->referral_code ?? '')) === '') {
                    $values['referral_code'] = $this->uniqueReferralCode();
                }

                $columns = array_flip(Schema::getColumnListing('users'));
                $values = array_filter(
                    $values,
                    static fn ($value, $column) => isset($columns[$column]),
                    ARRAY_FILTER_USE_BOTH
                );

                $user->forceFill($values);
                $user->save();

                $this->ensureWallet($user);

                return [$user->fresh(), $created];
            });

            $legacyPayload = [
                'email' => $email,
                'password' => (string) ($data['password'] ?? ''),
                'device_token' => (string) ($data['device_token'] ?? ''),
                'auth_provider' => $provider,
                'firebase_uid' => $uid,
                'firebase_id_token' => (string) $data['firebase_id_token'],
                'name' => (string) ($user->name ?? ''),
                'profile_image' => (string) ($user->profile_photo ?? ''),
                'id' => (string) ($data['id'] ?? ''),
            ];

            $legacyResponse = $this->dispatchLegacyLogin($request, $legacyPayload);
            $status = $legacyResponse->getStatusCode();
            $decoded = json_decode((string) $legacyResponse->getContent(), true);

            if (!is_array($decoded)) {
                return response()->json([
                    'success' => false,
                    'message' => 'A Laravel belepteto ervenytelen valaszt adott.',
                    'code' => 'legacy_login_invalid_response',
                ], 500);
            }

            if ($status < 200 || $status >= 300 || empty($decoded['token'])) {
                Log::error('VTaxi Firebase legacy login failed', [
                    'status' => $status,
                    'response' => $decoded,
                    'user_id' => $user->id,
                    'provider' => $provider,
                ]);

                return response()->json([
                    'success' => false,
                    'message' => $decoded['message'] ?? 'A Laravel belepesi token letrehozasa nem sikerult.',
                    'code' => 'legacy_login_failed',
                    'details' => app()->environment('production') ? null : $decoded,
                ], $status >= 400 ? $status : 500);
            }

            $phoneRequired = trim((string) ($user->phone ?? '')) === ''
                || (string) ($user->is_register ?? '0') !== '1';
            $decoded['firebase_account_created'] = $created;
            $decoded['email_verified'] = true;
            $decoded['phone_required'] = $phoneRequired;
            $decoded['auth_provider'] = $provider;

            if (isset($decoded['user']) && is_array($decoded['user'])) {
                $decoded['user']['phone'] = (string) ($user->phone ?? '');
                $decoded['user']['country_code'] = (string) ($user->country_code ?? '+36');
                $decoded['user']['email'] = (string) ($user->email ?? $email);
                $decoded['user']['name'] = (string) ($user->name ?? '');
                $decoded['user']['is_register'] = $phoneRequired ? '0' : '1';
                $decoded['user']['phone_required'] = $phoneRequired;
            }

            return response()->json($decoded, 200);
        } catch (\Illuminate\Validation\ValidationException $exception) {
            throw $exception;
        } catch (HttpResponseException $exception) {
            throw $exception;
        } catch (\Throwable $exception) {
            Log::error('VTaxi Firebase passenger login failed', [
                'provider' => $data['auth_provider'] ?? null,
                'exception' => $exception,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'A Firebase-fiok Veszpremi Taxi fiokhoz kotese nem sikerult.',
                'code' => 'firebase_backend_error',
            ], 500);
        }
    }

    public function completePhone(Request $request): JsonResponse
    {
        $data = $request->validate([
            'country_code' => ['required', 'string', 'regex:/^\+\d{1,4}$/'],
            'phone' => ['required', 'string', 'regex:/^\d{8,15}$/'],
        ]);

        $user = $request->user() ?: Auth::user();
        if (!$user) {
            $candidate = $request->get('user');
            if (is_object($candidate)) {
                $user = $candidate;
            }
        }
        if (!$user || (int) ($user->role_id ?? 0) !== 3) {
            return response()->json([
                'success' => false,
                'message' => 'Utas hitelesites szukseges.',
            ], 403);
        }

        $countryCode = trim((string) $data['country_code']);
        $phone = preg_replace('/\D+/', '', (string) $data['phone']);

        if ($countryCode === '+36') {
            if (str_starts_with($phone, '36') && strlen($phone) >= 10) {
                $phone = substr($phone, 2);
            }
            if (str_starts_with($phone, '06') && strlen($phone) >= 10) {
                $phone = substr($phone, 2);
            }
            if (str_starts_with($phone, '0') && strlen($phone) >= 9) {
                $phone = substr($phone, 1);
            }
        }

        if (strlen($phone) < 8 || strlen($phone) > 15) {
            return response()->json([
                'success' => false,
                'message' => 'A telefonszam hossza nem megfelelo.',
                'code' => 'invalid_phone',
            ], 422);
        }

        $duplicate = DB::table('users')
            ->where('role_id', 3)
            ->where('country_code', $countryCode)
            ->where('phone', $phone)
            ->where('id', '!=', $user->id)
            ->exists();

        if ($duplicate) {
            return response()->json([
                'success' => false,
                'message' => 'Ez a telefonszam mar masik utasfiokhoz tartozik.',
                'code' => 'phone_already_used',
            ], 409);
        }

        $values = [
            'country_code' => $countryCode,
            'phone' => $phone,
            'is_register' => 1,
            'step_0' => 1,
            'step_1' => 1,
            'step_2' => 1,
            'step_3' => 1,
            'updated_at' => now(),
        ];

        $columns = array_flip(Schema::getColumnListing('users'));
        $values = array_filter(
            $values,
            static fn ($value, $column) => isset($columns[$column]),
            ARRAY_FILTER_USE_BOTH
        );

        DB::table('users')->where('id', $user->id)->update($values);
        $fresh = $this->userClass()::query()->find($user->id);

        return response()->json([
            'success' => true,
            'message' => 'A telefonszam sikeresen elmentve.',
            'phone_required' => false,
            'user' => [
                'id' => (string) $fresh->id,
                'name' => (string) ($fresh->name ?? ''),
                'email' => (string) ($fresh->email ?? ''),
                'country_code' => (string) ($fresh->country_code ?? $countryCode),
                'phone' => (string) ($fresh->phone ?? $phone),
                'is_register' => (string) ($fresh->is_register ?? '1'),
            ],
        ]);
    }

    private function verifyFirebaseIdToken(string $idToken): array
    {
        $parts = explode('.', $idToken);
        if (count($parts) !== 3) {
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase munkamenet formatuma ervenytelen.',
                'code' => 'firebase_token_invalid',
            ], 401));
        }

        [$headerPart, $payloadPart, $signaturePart] = $parts;
        $header = json_decode($this->base64UrlDecode($headerPart), true);
        $payload = json_decode($this->base64UrlDecode($payloadPart), true);
        $signature = $this->base64UrlDecode($signaturePart);

        if (!is_array($header) || !is_array($payload) || ($header['alg'] ?? '') !== 'RS256') {
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase munkamenet fejlece ervenytelen.',
                'code' => 'firebase_token_invalid',
            ], 401));
        }

        $kid = trim((string) ($header['kid'] ?? ''));
        if ($kid === '') {
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase alairasi kulcs azonositoja hianyzik.',
                'code' => 'firebase_token_invalid',
            ], 401));
        }

        $certificates = Cache::remember('vtaxi_firebase_public_certs', 3300, function () {
            $response = Http::acceptJson()
                ->timeout(15)
                ->retry(2, 250)
                ->get('https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com');

            if (!$response->successful() || !is_array($response->json())) {
                throw new \RuntimeException('A Firebase nyilvanos alairasi kulcsai nem erhetoek el.');
            }

            return $response->json();
        });

        $certificate = is_array($certificates) ? ($certificates[$kid] ?? null) : null;
        if (!is_string($certificate) || $certificate === '') {
            Cache::forget('vtaxi_firebase_public_certs');
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase alairasi kulcs nem talalhato. Lepj be ujra.',
                'code' => 'firebase_signing_key_missing',
            ], 401));
        }

        $verified = openssl_verify(
            $headerPart . '.' . $payloadPart,
            $signature,
            $certificate,
            OPENSSL_ALGO_SHA256
        );

        if ($verified !== 1) {
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase munkamenet alairasa ervenytelen.',
                'code' => 'firebase_signature_invalid',
            ], 401));
        }

        $now = time();
        $issuer = 'https://securetoken.google.com/' . self::FIREBASE_PROJECT_ID;
        $audience = (string) ($payload['aud'] ?? '');
        $subject = trim((string) ($payload['sub'] ?? ''));
        $expiresAt = (int) ($payload['exp'] ?? 0);
        $issuedAt = (int) ($payload['iat'] ?? 0);
        $authTime = (int) ($payload['auth_time'] ?? 0);

        if (
            ($payload['iss'] ?? '') !== $issuer
            || $audience !== self::FIREBASE_PROJECT_ID
            || $subject === ''
            || strlen($subject) > 128
            || $expiresAt <= $now
            || $issuedAt > $now + 60
            || $authTime > $now + 60
        ) {
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase munkamenet lejart vagy nem ehhez a projekthez tartozik.',
                'code' => 'firebase_claims_invalid',
            ], 401));
        }

        $provider = (string) ($payload['firebase']['sign_in_provider'] ?? '');

        return [
            'localId' => $subject,
            'email' => (string) ($payload['email'] ?? ''),
            'emailVerified' => (bool) ($payload['email_verified'] ?? false),
            'displayName' => (string) ($payload['name'] ?? ''),
            'photoUrl' => (string) ($payload['picture'] ?? ''),
            'providerUserInfo' => $provider === '' ? [] : [
                ['providerId' => $provider],
            ],
        ];
    }

    private function base64UrlDecode(string $value): string
    {
        $remainder = strlen($value) % 4;
        if ($remainder > 0) {
            $value .= str_repeat('=', 4 - $remainder);
        }

        $decoded = base64_decode(strtr($value, '-_', '+/'), true);
        if (!is_string($decoded)) {
            throw new HttpResponseException(response()->json([
                'success' => false,
                'message' => 'A Firebase munkamenet kodolasa ervenytelen.',
                'code' => 'firebase_token_invalid',
            ], 401));
        }

        return $decoded;
    }

    private function dispatchLegacyLogin(Request $outerRequest, array $payload): Response
    {
        $legacyRoute = null;
        foreach (Route::getRoutes() as $route) {
            if (!$route instanceof RoutingRoute || !in_array('POST', $route->methods(), true)) {
                continue;
            }

            $uri = trim((string) $route->uri(), '/');
            if ($uri === 'api/user/login/password' || $uri === 'user/login/password') {
                $legacyRoute = $route;
                break;
            }
        }

        if (!$legacyRoute) {
            throw new \RuntimeException('A meglevo user/login/password route nem talalhato.');
        }

        $action = $legacyRoute->getActionName();
        if ($action === 'Closure' || !str_contains($action, '@')) {
            throw new \RuntimeException('A meglevo belepteto route nem controller metodusra mutat.');
        }

        [$class, $method] = explode('@', $action, 2);
        $subRequest = Request::create('/api/user/login/password', 'POST', $payload);
        $subRequest->headers->set('Accept', 'application/json');
        $subRequest->headers->set('Content-Type', 'application/json');

        $container = app();
        $originalRequest = $container->bound('request') ? $container->make('request') : null;
        $container->instance('request', $subRequest);

        $response = null;
        $directError = null;

        try {
            $response = $container->call([$container->make($class), $method], [
                'request' => $subRequest,
            ]);
        } catch (\Throwable $exception) {
            $directError = $exception;
        } finally {
            if ($originalRequest) {
                $container->instance('request', $originalRequest);
            } else {
                $container->instance('request', $outerRequest);
            }
        }

        if (!$response instanceof Response && !is_array($response)) {
            // FormRequest vagy mas specialis controller szignatura eseten a teljes
            // Laravel HTTP kernelen keresztul futtatjuk le ugyanazt a regi route-ot.
            $kernel = $container->make(\Illuminate\Contracts\Http\Kernel::class);
            $response = $kernel->handle($subRequest);

            if ($directError) {
                Log::info('VTaxi legacy login direct call fallback', [
                    'exception' => $directError->getMessage(),
                ]);
            }
        }

        if ($response instanceof Response) {
            return $response;
        }

        if (is_array($response)) {
            return response()->json($response);
        }

        throw new \RuntimeException('A meglevo belepteto nem HTTP valaszt adott.');
    }

    private function userClass(): string
    {
        if (class_exists(\App\Models\User::class)) {
            return \App\Models\User::class;
        }
        if (class_exists(\App\User::class)) {
            return \App\User::class;
        }
        throw new \RuntimeException('A Laravel User model nem talalhato.');
    }

    private function uniqueReferralCode(): string
    {
        do {
            $code = 'VAP' . random_int(1000, 9999);
        } while (DB::table('users')->where('referral_code', $code)->exists());

        return $code;
    }

    private function ensureWallet(object $user): void
    {
        if (!Schema::hasTable('wallets') || !Schema::hasColumn('wallets', 'user_id')) {
            return;
        }

        if (DB::table('wallets')->where('user_id', $user->id)->exists()) {
            return;
        }

        try {
            $columns = array_flip(Schema::getColumnListing('wallets'));
            $values = [
                'user_id' => $user->id,
                'balance' => 0,
                'currency' => 'HUF',
                'created_at' => now(),
                'updated_at' => now(),
            ];
            $values = array_filter(
                $values,
                static fn ($value, $column) => isset($columns[$column]),
                ARRAY_FILTER_USE_BOTH
            );
            DB::table('wallets')->insert($values);
        } catch (\Throwable $exception) {
            Log::warning('VTaxi wallet auto-create skipped', [
                'user_id' => $user->id,
                'exception' => $exception->getMessage(),
            ]);
        }
    }
}
PHP_CONTROLLER;
}

function vtaxi_routes_block(): string
{
    return <<<'ROUTES'

// VTAXI_FIREBASE_PASSENGER_ROUTES_20260730
Route::post('user/firebase-session', [\App\Http\Controllers\Api\VTaxiFirebaseAuthController::class, 'login']);
Route::post('user/complete-phone', [\App\Http\Controllers\Api\VTaxiFirebaseAuthController::class, 'completePhone'])
    ->middleware(\App\Http\Middleware\BearerTokenAuth::class);
ROUTES;
}

function vtaxi_lint_source(string $source): array
{
    try {
        token_get_all($source, TOKEN_PARSE);
    } catch (ParseError $exception) {
        throw new RuntimeException('PHP szintaktikai hiba: ' . $exception->getMessage());
    }

    return [
        'mode' => 'token_get_all(TOKEN_PARSE)',
        'output' => 'A generalt controller PHP szintaxisa ervenyes.',
    ];
}

function vtaxi_schema_state(): array
{
    $columns = [];
    foreach (['firebase_uid', 'firebase_provider', 'firebase_email_verified_at'] as $column) {
        $columns[$column] = Illuminate\Support\Facades\Schema::hasColumn('users', $column);
    }

    return $columns;
}

function vtaxi_install_schema(): array
{
    $changes = [];

    if (!Illuminate\Support\Facades\Schema::hasColumn('users', 'firebase_uid')) {
        Illuminate\Support\Facades\Schema::table('users', function ($table) {
            $table->string('firebase_uid', 128)->nullable()->unique()->after('email');
        });
        $changes[] = 'users.firebase_uid letrehozva.';
    }

    if (!Illuminate\Support\Facades\Schema::hasColumn('users', 'firebase_provider')) {
        Illuminate\Support\Facades\Schema::table('users', function ($table) {
            $table->string('firebase_provider', 32)->nullable()->after('firebase_uid');
        });
        $changes[] = 'users.firebase_provider letrehozva.';
    }

    if (!Illuminate\Support\Facades\Schema::hasColumn('users', 'firebase_email_verified_at')) {
        Illuminate\Support\Facades\Schema::table('users', function ($table) {
            $table->timestamp('firebase_email_verified_at')->nullable()->after('firebase_provider');
        });
        $changes[] = 'users.firebase_email_verified_at letrehozva.';
    }

    if ($changes === []) {
        $changes[] = 'A Firebase users oszlopok mar leteznek.';
    }

    return $changes;
}

function vtaxi_checks(string $controllerSource, string $routesSource): array
{
    $checks = [
        'controller_marker' => str_contains($controllerSource, VTAXI_FIREBASE_CONTROLLER_MARKER),
        'firebase_signature_verify' => str_contains($controllerSource, 'openssl_verify'),
        'email_verification_required' => str_contains($controllerSource, 'email_not_verified'),
        'customer_role_3' => str_contains($controllerSource, "'role_id' => 3"),
        'phone_required' => str_contains($controllerSource, 'phone_required'),
        'complete_phone' => str_contains($controllerSource, 'function completePhone'),
        'legacy_login_reused' => str_contains($controllerSource, 'dispatchLegacyLogin'),
        'route_marker' => str_contains($routesSource, VTAXI_FIREBASE_ROUTE_MARKER),
        'login_route' => str_contains($routesSource, "user/firebase-session"),
        'phone_route' => str_contains($routesSource, "user/complete-phone"),
    ];

    foreach ($checks as $value) {
        if ($value !== true) {
            throw new RuntimeException('Az alapellenorzes sikertelen: ' . vtaxi_json($checks));
        }
    }

    return $checks;
}

function vtaxi_check(string $root): array
{
    vtaxi_bootstrap($root);

    $controllerPath = vtaxi_controller_path($root);
    $routesPath = vtaxi_routes_path($root);
    $generatedController = vtaxi_controller_source();
    $currentRoutes = (string) file_get_contents($routesPath);
    $futureRoutes = str_contains($currentRoutes, VTAXI_FIREBASE_ROUTE_MARKER)
        ? $currentRoutes
        : rtrim($currentRoutes) . "\n" . vtaxi_routes_block() . "\n";

    return [
        'installed' => is_file($controllerPath)
            && str_contains((string) file_get_contents($controllerPath), VTAXI_FIREBASE_CONTROLLER_MARKER)
            && str_contains($currentRoutes, VTAXI_FIREBASE_ROUTE_MARKER),
        'version' => VTAXI_FIREBASE_PATCH_VERSION,
        'controller' => $controllerPath,
        'routes' => $routesPath,
        'schema_before' => vtaxi_schema_state(),
        'lint' => vtaxi_lint_source($generatedController),
        'checks' => vtaxi_checks($generatedController, $futureRoutes),
        'next' => 'INSTALL utan az UTASAPP user/firebase-session vegpontot hasznal, es telefonszam nelkul kotelezo profilkaput kap.',
    ];
}

function vtaxi_install(string $root): array
{
    vtaxi_bootstrap($root);

    $controllerPath = vtaxi_controller_path($root);
    $routesPath = vtaxi_routes_path($root);
    $controllerSource = vtaxi_controller_source();
    $routesSource = (string) file_get_contents($routesPath);
    $backupDir = $root . '/storage/app/vtaxi-backups';

    if (!is_dir($backupDir) && !mkdir($backupDir, 0775, true) && !is_dir($backupDir)) {
        throw new RuntimeException('Nem sikerult letrehozni a backup mappat.');
    }

    $stamp = date('Ymd-His');
    $backups = [];

    if (is_file($controllerPath)) {
        $controllerBackup = $backupDir . '/VTaxiFirebaseAuthController.php.' . $stamp . '.bak';
        if (!copy($controllerPath, $controllerBackup)) {
            throw new RuntimeException('Nem sikerult elmenteni a controller backupot.');
        }
        $backups[] = $controllerBackup;
    }

    $routesBackup = $backupDir . '/api.php.' . $stamp . '.firebase-passenger-before.bak';
    if (!copy($routesPath, $routesBackup)) {
        throw new RuntimeException('Nem sikerult elmenteni a routes/api.php backupot.');
    }
    $backups[] = $routesBackup;

    vtaxi_lint_source($controllerSource);

    if (file_put_contents($controllerPath, $controllerSource) === false) {
        throw new RuntimeException('Nem sikerult kiirni a Firebase controllert.');
    }

    if (!str_contains($routesSource, VTAXI_FIREBASE_ROUTE_MARKER)) {
        $routesSource = rtrim($routesSource) . "\n" . vtaxi_routes_block() . "\n";
        if (file_put_contents($routesPath, $routesSource) === false) {
            throw new RuntimeException('Nem sikerult kiegesziteni a routes/api.php fajlt.');
        }
    }

    $schemaChanges = vtaxi_install_schema();

    try {
        Illuminate\Support\Facades\Artisan::call('route:clear');
        Illuminate\Support\Facades\Artisan::call('config:clear');
    } catch (Throwable $exception) {
        // A fajlok mar telepitve vannak; cache clear hiba csak jelzes.
    }

    $installedController = (string) file_get_contents($controllerPath);
    $installedRoutes = (string) file_get_contents($routesPath);

    return [
        'installed' => true,
        'version' => VTAXI_FIREBASE_PATCH_VERSION,
        'backups' => $backups,
        'schema_changes' => $schemaChanges,
        'schema_after' => vtaxi_schema_state(),
        'lint' => vtaxi_lint_source($installedController),
        'checks' => vtaxi_checks($installedController, $installedRoutes),
        'endpoints' => [
            'POST /api/user/firebase-session',
            'POST /api/user/complete-phone (Bearer token)',
        ],
        'next_test' => 'Ellenorzott e-mail vagy Google belepes utan az utas jelenjen meg az adminban; telefonszam nelkul az app kerje be kotelezoen.',
    ];
}

function vtaxi_render(string $title, ?array $result = null, ?string $error = null): never
{
    $base = strtok((string) ($_SERVER['REQUEST_URI'] ?? ''), '?');
    $checkUrl = $base . '?key=' . rawurlencode(VTAXI_FIREBASE_PATCH_KEY) . '&action=check';
    $installUrl = $base . '?key=' . rawurlencode(VTAXI_FIREBASE_PATCH_KEY) . '&action=install';

    echo '<!doctype html><html lang="hu"><head><meta charset="utf-8">';
    echo '<meta name="viewport" content="width=device-width,initial-scale=1">';
    echo '<title>' . vtaxi_h($title) . '</title>';
    echo '<style>body{font-family:Arial,sans-serif;max-width:980px;margin:32px auto;padding:0 18px;background:#f6f7f9;color:#1f2937}';
    echo '.card{background:#fff;border:1px solid #dfe3e8;border-radius:14px;padding:22px;box-shadow:0 8px 30px rgba(0,0,0,.05)}';
    echo 'pre{white-space:pre-wrap;word-break:break-word;background:#111827;color:#e5e7eb;padding:16px;border-radius:10px}';
    echo '.ok{color:#087443}.err{color:#b42318}a.btn{display:inline-block;padding:11px 16px;border-radius:9px;background:#111827;color:#fff;text-decoration:none;margin-right:10px}</style></head><body>';
    echo '<div class="card"><h1>Veszpremi Taxi - Firebase utasfiok backend patch</h1>';
    echo '<p><strong>Verzio:</strong> ' . vtaxi_h(VTAXI_FIREBASE_PATCH_VERSION) . '</p>';
    echo '<p>Eloszor CHECK, utana INSTALL. A telepites fajl-backupot keszit.</p>';
    echo '<p><a class="btn" href="' . vtaxi_h($checkUrl) . '">CHECK</a>';
    echo '<a class="btn" href="' . vtaxi_h($installUrl) . '" onclick="return confirm(\'Telepited a Firebase utasfiok javitasat?\')">INSTALL</a></p>';

    if ($error !== null) {
        echo '<h2 class="err">Hiba</h2><pre>' . vtaxi_h($error) . '</pre>';
    }
    if ($result !== null) {
        echo '<h2 class="ok">Eredmeny</h2><pre>' . vtaxi_h(vtaxi_json($result)) . '</pre>';
    }

    echo '</div></body></html>';
    exit;
}

try {
    if (!hash_equals(VTAXI_FIREBASE_PATCH_KEY, (string) ($_GET['key'] ?? ''))) {
        http_response_code(403);
        vtaxi_render('Hibas kulcs', null, 'Hibas telepitesi kulcs.');
    }

    $root = vtaxi_find_root();
    $action = strtolower(trim((string) ($_GET['action'] ?? '')));

    if ($action === 'check') {
        vtaxi_render('CHECK', vtaxi_check($root));
    }
    if ($action === 'install') {
        vtaxi_render('INSTALL', vtaxi_install($root));
    }

    vtaxi_render('Firebase utasfiok patch');
} catch (Throwable $exception) {
    http_response_code(500);
    vtaxi_render('Hiba', null, $exception->getMessage());
}
