<?php

declare(strict_types=1);

use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

header('Content-Type: text/plain; charset=UTF-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

const SETUP_KEY = 'VTAXI-PASSENGER-2026-SETUP';
const PASSENGER_EMAIL = 'utas@veszpremitaxi.hu';
const PASSENGER_PASSWORD = 'Vap12345';
const PREFERRED_PASSENGER_ID = 9;

if (!hash_equals(SETUP_KEY, (string) ($_GET['key'] ?? ''))) {
    http_response_code(403);
    exit("Hibas telepitesi kulcs.\n");
}

$root = dirname(__DIR__);
$autoload = $root . '/vendor/autoload.php';
$bootstrap = $root . '/bootstrap/app.php';

if (!is_file($autoload) || !is_file($bootstrap)) {
    http_response_code(500);
    exit("Nem talalom a Laravel projektet. A fajlt a projekt public mappajaba toltsd fel.\n");
}

require $autoload;
$app = require_once $bootstrap;
$app->make(Kernel::class)->bootstrap();

try {
    $passenger = DB::table('users')
        ->where('email', PASSENGER_EMAIL)
        ->where('role_id', 3)
        ->first();

    if (!$passenger) {
        $passenger = DB::table('users')
            ->where('id', PREFERRED_PASSENGER_ID)
            ->where('role_id', 3)
            ->first();
    }

    if (!$passenger) {
        $passenger = DB::table('users')
            ->where('role_id', 3)
            ->orderBy('id')
            ->first();
    }

    if (!$passenger) {
        http_response_code(404);
        exit("Nem talaltam frissitheto utas felhasznalot. Nem tortent modositas.\n");
    }

    $values = [
        'name' => 'VAP Bemutato Utas',
        'email' => PASSENGER_EMAIL,
        'password' => Hash::make(PASSENGER_PASSWORD),
        'role_id' => 3,
        'login_device' => 'email',
        'is_verified' => 1,
        'email_verified_at' => now(),
        'verified_at' => now(),
        'status' => 'active',
        'is_register' => 1,
        'step_0' => 1,
        'step_1' => 1,
        'step_2' => 1,
        'step_3' => 1,
        'country_code' => '+36',
        'updated_at' => now(),
    ];

    // Only write fields that truly exist in this installation.
    $values = array_filter(
        $values,
        static fn(mixed $value, string $column): bool => Schema::hasColumn('users', $column),
        ARRAY_FILTER_USE_BOTH
    );

    DB::table('users')->where('id', $passenger->id)->update($values);

    @unlink(__FILE__);

    echo "KESZ. A bemutato utas belepese beallitva.\n";
    echo "Felhasznalo ID: {$passenger->id}\n";
    echo "E-mail: " . PASSENGER_EMAIL . "\n";
    echo "Jelszo: " . PASSENGER_PASSWORD . "\n";
    echo "A telepito megprobalta sajat magat torolni.\n";
} catch (Throwable $error) {
    http_response_code(500);
    echo "HIBA: " . $error->getMessage() . "\n";
}
