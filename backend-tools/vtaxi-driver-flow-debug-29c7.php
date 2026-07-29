<?php

/*
 * Veszpremi Taxi - standalone passenger + driver flow debug collector + viewer
 *
 * Version: 2026-07-29-role2-role3-v2
 *
 * - Does not modify routes/api.php
 * - Does not modify database data
 * - Does not chmod anything
 * - Does not delete itself
 * - POST requests are authenticated with the app's existing Bearer token
 * - Accepts authenticated driver (role_id 2) and passenger (role_id 3) events
 * - GET viewer is protected by a separate key
 */

header('X-Robots-Tag: noindex, nofollow', true);
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

const VTAXI_VIEWER_KEY = 'faIkB8uSQHJsmBKtGrTcpQsewDrmVbLa';
const VTAXI_MAX_LOG_BYTES = 5242880;
const VTAXI_MAX_VISIBLE_RECORDS = 800;
const VTAXI_COLLECTOR_VERSION = '2026-07-29-role2-role3-v2';
const VTAXI_DRIVER_ROLE_ID = 2;
const VTAXI_PASSENGER_ROLE_ID = 3;

function vtaxi_json_response($payload, $status)
{
    http_response_code((int) $status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function vtaxi_html($value)
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function vtaxi_has_text($haystack, $needle)
{
    return strpos((string) $haystack, (string) $needle) !== false;
}

function vtaxi_role_name($roleId)
{
    if ((int) $roleId === VTAXI_DRIVER_ROLE_ID) {
        return 'driver';
    }

    if ((int) $roleId === VTAXI_PASSENGER_ROLE_ID) {
        return 'passenger';
    }

    return 'unknown';
}

function vtaxi_sanitize($value, $depth = 0)
{
    if ($depth > 6) {
        return '[depth-limit]';
    }

    if ($value === null || is_bool($value) || is_int($value) || is_float($value)) {
        return $value;
    }

    if (is_string($value)) {
        return function_exists('mb_substr')
            ? mb_substr($value, 0, 800)
            : substr($value, 0, 800);
    }

    if (is_object($value)) {
        $value = (array) $value;
    }

    if (!is_array($value)) {
        $text = (string) $value;
        return function_exists('mb_substr') ? mb_substr($text, 0, 800) : substr($text, 0, 800);
    }

    $result = array();
    $count = 0;

    foreach ($value as $key => $item) {
        $count++;
        if ($count > 100) {
            $result['_truncated'] = true;
            break;
        }

        $keyString = (string) $key;
        $lowerKey = strtolower($keyString);

        $blocked = array(
            'token', 'authorization', 'password', 'secret', 'phone', 'email',
            'name', 'address', 'photo', 'avatar', 'profile_image'
        );

        $skip = false;
        foreach ($blocked as $blockedPart) {
            if (vtaxi_has_text($lowerKey, $blockedPart)) {
                $skip = true;
                break;
            }
        }

        if ($skip) {
            continue;
        }

        $result[$keyString] = vtaxi_sanitize($item, $depth + 1);
    }

    return $result;
}

function vtaxi_project_root()
{
    $root = realpath(__DIR__ . '/..');
    return $root === false ? null : $root;
}

function vtaxi_log_path($root)
{
    return rtrim($root, DIRECTORY_SEPARATOR) . '/storage/logs/vtaxi-driver-flow.jsonl';
}

function vtaxi_append_record($logPath, $record)
{
    $directory = dirname($logPath);
    if (!is_dir($directory) || !is_writable($directory)) {
        throw new RuntimeException('A storage/logs konyvtar nem irhato.');
    }

    if (is_file($logPath) && filesize($logPath) > VTAXI_MAX_LOG_BYTES) {
        $rotated = $logPath . '.1';
        if (is_file($rotated)) {
            @unlink($rotated);
        }
        @rename($logPath, $rotated);
    }

    $line = json_encode($record, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($line === false) {
        throw new RuntimeException('A debug rekord nem alakithato JSON formatumra.');
    }

    if (file_put_contents($logPath, $line . PHP_EOL, FILE_APPEND | LOCK_EX) === false) {
        throw new RuntimeException('A debug naplo nem irhato.');
    }
}

function vtaxi_existing_columns($table, $requested, $schema)
{
    $result = array();
    foreach ($requested as $column) {
        try {
            if ($schema->hasColumn($table, $column)) {
                $result[] = $column;
            }
        } catch (Throwable $ignored) {
            // A snapshot hiba nem blokkolhatja a fo debug esemenyt.
        }
    }
    return $result;
}

function vtaxi_safe_object($value)
{
    if ($value === null) {
        return null;
    }

    $data = (array) $value;
    $coordinateKeys = array(
        'latitude', 'longitude', 'last_latitude', 'last_longitude',
        'pickup_latitude', 'pickup_longitude', 'dropoff_latitude', 'dropoff_longitude'
    );

    foreach ($coordinateKeys as $key) {
        if (isset($data[$key]) && is_numeric($data[$key])) {
            $data[$key] = round((float) $data[$key], 5);
        }
    }

    return vtaxi_sanitize($data);
}

function vtaxi_booking_visible_to_actor($booking, $actorId, $roleId, $bookingId)
{
    if ($booking === null) {
        return false;
    }

    $bookingData = (array) $booking;

    if ((int) $roleId === VTAXI_PASSENGER_ROLE_ID) {
        return isset($bookingData['user_id']) && (int) $bookingData['user_id'] === (int) $actorId;
    }

    if ((int) $roleId !== VTAXI_DRIVER_ROLE_ID) {
        return false;
    }

    if (isset($bookingData['driver_id']) && (int) $bookingData['driver_id'] === (int) $actorId) {
        return true;
    }

    try {
        $cache = app('cache');
        $offer = $cache->get('booking_offer_' . (int) $bookingId . '_' . (int) $actorId);
        if ($offer !== null) {
            return true;
        }

        $notifiedDrivers = $cache->get('booking_' . (int) $bookingId . '_notified_drivers', array());
        if (is_array($notifiedDrivers)) {
            foreach ($notifiedDrivers as $notifiedDriverId) {
                if ((int) $notifiedDriverId === (int) $actorId) {
                    return true;
                }
            }
        }
    } catch (Throwable $ignored) {
        // A cache ellenorzes hibaja nem blokkolhatja a debug esemenyt.
    }

    return false;
}

function vtaxi_snapshot($actorId, $roleId, $bookingId)
{
    $roleName = vtaxi_role_name($roleId);
    $snapshot = array(
        'actor' => null,
        'actor_role' => $roleName,
        'driver' => null,
        'passenger' => null,
        'booking' => null,
        'booking_access' => null,
        'latest_location' => null,
        'latest_attendance' => null,
        'cache' => array(),
        'snapshot_error' => null,
    );

    try {
        $db = app('db');
        $schema = app('db')->connection()->getSchemaBuilder();

        if ($schema->hasTable('users')) {
            $columns = vtaxi_existing_columns('users', array(
                'id', 'role_id', 'status', 'is_online', 'is_verified',
                'current_booking_id', 'last_latitude', 'last_longitude',
                'last_location_at', 'updated_at'
            ), $schema);

            if (!empty($columns)) {
                $actor = vtaxi_safe_object(
                    $db->table('users')->where('id', (int) $actorId)->first($columns)
                );
                $snapshot['actor'] = $actor;
                if ((int) $roleId === VTAXI_DRIVER_ROLE_ID) {
                    $snapshot['driver'] = $actor;
                } elseif ((int) $roleId === VTAXI_PASSENGER_ROLE_ID) {
                    $snapshot['passenger'] = $actor;
                }
            }
        }

        if ($bookingId !== null && $schema->hasTable('bookings')) {
            $columns = vtaxi_existing_columns('bookings', array(
                'id', 'status', 'driver_id', 'user_id', 'ride_type_id',
                'is_confirm', 'pickup_latitude', 'pickup_longitude',
                'dropoff_latitude', 'dropoff_longitude', 'accepted_at',
                'driver_arrival_time', 'pickup_time', 'dropoff_time',
                'started_at', 'completed_at', 'auto_arriving_scheduled_at',
                'updated_at'
            ), $schema);

            if (!empty($columns)) {
                $rawBooking = $db->table('bookings')->where('id', (int) $bookingId)->first($columns);
                $canViewBooking = vtaxi_booking_visible_to_actor($rawBooking, $actorId, $roleId, $bookingId);
                $snapshot['booking_access'] = $canViewBooking;
                if ($canViewBooking) {
                    $snapshot['booking'] = vtaxi_safe_object($rawBooking);
                }
            }
        }

        if ((int) $roleId === VTAXI_DRIVER_ROLE_ID && $schema->hasTable('driver_locations')) {
            $columns = vtaxi_existing_columns('driver_locations', array(
                'id', 'driver_id', 'latitude', 'longitude', 'is_active',
                'recorded_at', 'created_at', 'updated_at'
            ), $schema);

            if (!empty($columns)) {
                $snapshot['latest_location'] = vtaxi_safe_object(
                    $db->table('driver_locations')
                        ->where('driver_id', (int) $actorId)
                        ->orderByDesc('id')
                        ->first($columns)
                );
            }
        }

        if ((int) $roleId === VTAXI_DRIVER_ROLE_ID && $schema->hasTable('driver_attendances')) {
            $columns = vtaxi_existing_columns('driver_attendances', array(
                'id', 'driver_id', 'online_time', 'offline_time', 'date',
                'created_at', 'updated_at'
            ), $schema);

            if (!empty($columns)) {
                $snapshot['latest_attendance'] = vtaxi_safe_object(
                    $db->table('driver_attendances')
                        ->where('driver_id', (int) $actorId)
                        ->orderByDesc('id')
                        ->first($columns)
                );
            }
        }

        if ($bookingId !== null && $snapshot['booking_access'] === true) {
            $cache = app('cache');
            $cacheData = array(
                'notification_round' => $cache->get('booking_' . $bookingId . '_notification_round'),
                'notified_drivers' => $cache->get('booking_' . $bookingId . '_notified_drivers', array()),
            );

            if ((int) $roleId === VTAXI_DRIVER_ROLE_ID) {
                $cacheData['offer'] = $cache->get('booking_offer_' . $bookingId . '_' . $actorId);
            }

            $snapshot['cache'] = vtaxi_sanitize($cacheData);
        }
    } catch (Throwable $error) {
        $snapshot['snapshot_error'] = get_class($error) . ': ' . $error->getMessage();
    }

    return $snapshot;
}

function vtaxi_viewer_key_valid()
{
    $provided = '';
    if (isset($_GET['key'])) {
        $provided = (string) $_GET['key'];
    } elseif (isset($_POST['key'])) {
        $provided = (string) $_POST['key'];
    }

    return hash_equals(VTAXI_VIEWER_KEY, $provided);
}

function vtaxi_render_viewer($root)
{
    if (!vtaxi_viewer_key_valid()) {
        http_response_code(403);
        exit('Hibas hozzaferesi kulcs.');
    }

    $logPath = vtaxi_log_path($root);

    if (isset($_GET['selftest'])) {
        vtaxi_json_response(array(
            'success' => true,
            'collector_version' => VTAXI_COLLECTOR_VERSION,
            'accepted_roles' => array(
                'driver' => VTAXI_DRIVER_ROLE_ID,
                'passenger' => VTAXI_PASSENGER_ROLE_ID,
            ),
            'php_version' => PHP_VERSION,
            'project_root_found' => is_dir($root),
            'autoload_found' => is_file($root . '/vendor/autoload.php'),
            'bootstrap_found' => is_file($root . '/bootstrap/app.php'),
            'storage_logs_found' => is_dir(dirname($logPath)),
            'storage_logs_writable' => is_writable(dirname($logPath)),
            'collector_file' => basename(__FILE__),
        ), 200);
    }

    if (isset($_GET['download'])) {
        header('Content-Type: application/x-ndjson; charset=utf-8');
        header('Content-Disposition: attachment; filename="vtaxi-driver-flow-' . date('Ymd-His') . '.jsonl"');
        if (is_file($logPath)) {
            readfile($logPath);
        }
        exit;
    }

    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST' && isset($_POST['action']) && $_POST['action'] === 'clear') {
        if (is_file($logPath)) {
            file_put_contents($logPath, '', LOCK_EX);
        }
        header('Location: ' . basename(__FILE__) . '?key=' . rawurlencode(VTAXI_VIEWER_KEY));
        exit;
    }

    $lines = is_file($logPath)
        ? file($logPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES)
        : array();

    if (!is_array($lines)) {
        $lines = array();
    }

    $lines = array_slice($lines, -VTAXI_MAX_VISIBLE_RECORDS);
    $records = array();

    foreach ($lines as $line) {
        $decoded = json_decode($line, true);
        if (is_array($decoded)) {
            $records[] = $decoded;
        }
    }

    $records = array_reverse($records);

    header('Content-Type: text/html; charset=utf-8');
    ?>
<!doctype html>
<html lang="hu">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>VTaxi utas es sofor flow debug</title>
<style>
body{font-family:Arial,sans-serif;margin:24px;background:#f4f6f8;color:#17202a}.bar{display:flex;gap:12px;align-items:center;flex-wrap:wrap}.card{background:#fff;border:1px solid #dfe4ea;border-radius:10px;padding:14px;margin:12px 0}.meta{display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:8px;font-size:14px}.event{font-weight:700;color:#8a5200}pre{white-space:pre-wrap;word-break:break-word;background:#101820;color:#e7eef5;padding:12px;border-radius:8px;max-height:440px;overflow:auto}a,button{background:#f2a900;color:#111;border:0;border-radius:7px;padding:9px 13px;text-decoration:none;font-weight:700;cursor:pointer}.danger{background:#eee;color:#8b0000}.muted{color:#667085}.ok{background:#e8f7ec;border-left:4px solid #159447;padding:12px;margin:12px 0}.role{font-weight:700;color:#005a8d}
</style>
</head>
<body>
<h1>Veszpremi Taxi - utas es sofor flow debug</h1>
<div class="ok">A gyujto aktiv. Sofor role_id=2 es utas role_id=3 esemenyeket fogad. Nem modosit route-ot, adatbazist vagy jogosultsagot.</div>
<div class="bar">
<a href="?key=<?php echo vtaxi_html(VTAXI_VIEWER_KEY); ?>">Frissites</a>
<a href="?key=<?php echo vtaxi_html(VTAXI_VIEWER_KEY); ?>&selftest=1">Onellenorzes</a>
<a href="?key=<?php echo vtaxi_html(VTAXI_VIEWER_KEY); ?>&download=1">JSONL letoltes</a>
<form method="post" onsubmit="return confirm('Biztosan torlod a debug naplot?')">
<input type="hidden" name="key" value="<?php echo vtaxi_html(VTAXI_VIEWER_KEY); ?>">
<input type="hidden" name="action" value="clear">
<button class="danger" type="submit">Naplo uritese</button>
</form>
<span class="muted"><?php echo count($records); ?> esemeny lathato</span>
</div>
<?php if (empty($records)): ?>
<div class="card">Meg nincs rogzitett app-esemeny.</div>
<?php endif; ?>
<?php foreach ($records as $record): ?>
<?php
    $recordRole = isset($record['actor_role'])
        ? (string) $record['actor_role']
        : (isset($record['driver_id']) && $record['driver_id'] !== null ? 'driver' : 'unknown');
    $recordActorId = isset($record['actor_id'])
        ? $record['actor_id']
        : (isset($record['driver_id']) ? $record['driver_id'] : '');
?>
<div class="card">
<div class="meta">
<div><strong>Ido:</strong> <?php echo vtaxi_html(isset($record['server_time']) ? $record['server_time'] : ''); ?></div>
<div><strong>Esemeny:</strong> <span class="event"><?php echo vtaxi_html(isset($record['event']) ? $record['event'] : ''); ?></span></div>
<div><strong>Szerep:</strong> <span class="role"><?php echo vtaxi_html($recordRole); ?></span></div>
<div><strong>Felhasznalo:</strong> <?php echo vtaxi_html($recordActorId); ?></div>
<div><strong>Sorrend:</strong> <?php echo vtaxi_html(isset($record['sequence']) ? $record['sequence'] : ''); ?></div>
<div><strong>Fuvar:</strong> <?php echo vtaxi_html(isset($record['booking_id']) ? $record['booking_id'] : ''); ?></div>
<div><strong>Kepernyo:</strong> <?php echo vtaxi_html(isset($record['route']) ? $record['route'] : ''); ?></div>
</div>
<details>
<summary>Teljes szurt rekord</summary>
<pre><?php echo vtaxi_html(json_encode($record, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)); ?></pre>
</details>
</div>
<?php endforeach; ?>
</body>
</html>
<?php
    exit;
}

$method = isset($_SERVER['REQUEST_METHOD']) ? strtoupper((string) $_SERVER['REQUEST_METHOD']) : 'GET';
$root = vtaxi_project_root();

if ($root === null) {
    vtaxi_json_response(array('success' => false, 'message' => 'Laravel project root not found.'), 500);
}

if ($method === 'GET' || ($method === 'POST' && isset($_POST['key']))) {
    vtaxi_render_viewer($root);
}

if ($method !== 'POST') {
    vtaxi_json_response(array('success' => false, 'message' => 'POST required.'), 405);
}

if (empty($_SERVER['HTTP_AUTHORIZATION']) && !empty($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
    $_SERVER['HTTP_AUTHORIZATION'] = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
}

$autoload = $root . '/vendor/autoload.php';
$bootstrap = $root . '/bootstrap/app.php';

if (!is_file($autoload) || !is_file($bootstrap)) {
    vtaxi_json_response(array('success' => false, 'message' => 'Laravel bootstrap files not found.'), 500);
}

require $autoload;
$app = require $bootstrap;
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$request = Illuminate\Http\Request::capture();
$logPath = vtaxi_log_path($root);

try {
    $middleware = $app->make(App\Http\Middleware\BearerTokenAuth::class);

    $response = $middleware->handle($request, function ($authenticatedRequest) use ($logPath) {
        $actor = Illuminate\Support\Facades\Auth::user();
        if (!$actor && method_exists($authenticatedRequest, 'get')) {
            $candidate = $authenticatedRequest->get('user');
            if (is_object($candidate)) {
                $actor = $candidate;
            }
        }

        $roleId = $actor && isset($actor->role_id) ? (int) $actor->role_id : 0;
        $acceptedRoles = array(VTAXI_DRIVER_ROLE_ID, VTAXI_PASSENGER_ROLE_ID);

        if (!$actor || !in_array($roleId, $acceptedRoles, true)) {
            return response()->json(array(
                'success' => false,
                'message' => 'Driver or passenger authentication required.',
                'accepted_roles' => array(
                    'driver' => VTAXI_DRIVER_ROLE_ID,
                    'passenger' => VTAXI_PASSENGER_ROLE_ID,
                ),
            ), 403);
        }

        $payload = $authenticatedRequest->json()->all();
        if (!is_array($payload) || empty($payload)) {
            $payload = $authenticatedRequest->all();
        }

        $event = isset($payload['event']) ? trim((string) $payload['event']) : '';
        $sessionId = isset($payload['session_id']) ? trim((string) $payload['session_id']) : '';
        $sequence = isset($payload['sequence']) ? (int) $payload['sequence'] : 0;
        $bookingRaw = isset($payload['booking_id']) ? trim((string) $payload['booking_id']) : '';
        $bookingId = ctype_digit($bookingRaw) ? (int) $bookingRaw : null;

        if ($event === '' || strlen($event) > 120 || $sessionId === '' || strlen($sessionId) > 120 || $sequence < 1) {
            return response()->json(array(
                'success' => false,
                'message' => 'Invalid debug payload.',
            ), 422);
        }

        $roleName = vtaxi_role_name($roleId);
        $actorId = (int) $actor->id;

        $record = array(
            'server_time' => date(DATE_ATOM),
            'collector_version' => VTAXI_COLLECTOR_VERSION,
            'event' => $event,
            'session_id' => $sessionId,
            'sequence' => $sequence,
            'actor_id' => $actorId,
            'actor_role_id' => $roleId,
            'actor_role' => $roleName,
            'driver_id' => $roleId === VTAXI_DRIVER_ROLE_ID ? $actorId : null,
            'passenger_id' => $roleId === VTAXI_PASSENGER_ROLE_ID ? $actorId : null,
            'booking_id' => $bookingId,
            'client_time' => isset($payload['client_time']) ? substr((string) $payload['client_time'], 0, 80) : '',
            'app_version' => isset($payload['app_version']) ? substr((string) $payload['app_version'], 0, 40) : '',
            'route' => isset($payload['route']) ? substr((string) $payload['route'], 0, 160) : '',
            'data' => vtaxi_sanitize(isset($payload['data']) && is_array($payload['data']) ? $payload['data'] : array()),
            'snapshot' => vtaxi_snapshot($actorId, $roleId, $bookingId),
        );

        vtaxi_append_record($logPath, $record);

        return response()->json(array(
            'success' => true,
            'message' => 'Debug event recorded.',
            'data' => array(
                'event' => $event,
                'sequence' => $sequence,
                'actor_role' => $roleName,
                'collector_version' => VTAXI_COLLECTOR_VERSION,
            ),
        ), 200);
    });

    $response->send();
    exit;
} catch (Throwable $error) {
    try {
        Illuminate\Support\Facades\Log::warning('VTAXI standalone passenger/driver flow debug failed', array(
            'exception_class' => get_class($error),
            'exception_message' => $error->getMessage(),
        ));
    } catch (Throwable $ignored) {
        // Do not expose or escalate logging failures.
    }

    vtaxi_json_response(array(
        'success' => false,
        'message' => 'Debug event was not recorded.',
    ), 500);
}
