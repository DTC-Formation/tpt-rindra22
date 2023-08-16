<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Image Driver
    |--------------------------------------------------------------------------
    |
    | Intervention Image supports "GD Library" and "Imagick" to process images
    | internally. You may choose one of them according to your PHP
    | configuration. By default PHP's "GD Library" implementation is used.
    |
    | Supported: "gd", "imagick"
    |
    */

    'driver' => 'gd',
    'posts' => [
        'default' => [
            'width' => 480,
            'height' => 320
        ]
    ],
    'users' => [
        'default' => [
            'width' => 120,
            'height' => 180
        ]
    ],

];
