<?php
namespace App\Traits;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;

trait SaveImageTrait{
    public function save($image, $path = 'public')
    {
        if(!$image)
        {
            return null;
        }

        $filename = time().'.png';
        // save image
        Storage::disk($path)->put($filename, base64_decode($image));

        return "storage/$path/$filename";
    }
}
