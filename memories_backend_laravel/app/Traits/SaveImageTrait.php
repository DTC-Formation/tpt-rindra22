<?php
namespace App\Traits;

use App\Models\ImagePost;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Intervention\Image\Facades\Image;

trait SaveImageTrait{
    public function save($files = [], $path = 'public',$post_id,$isUpdated = false)
    {
        if($isUpdated) {
            $old_image = ImagePost::where('post_id', $post_id)->get();
            if($old_image != null) {
                $old_image->each(function($image) {

                    if (file_exists(storage_path("app/public/".$image->path))) {
                        unlink(storage_path("app/public/".$image->path));
                    }
                    $image->delete();
                });
            }
        }
        if($files != null) {
            if(is_array($files)) {
                foreach($files as $file) {
                    $folder = uniqid() . '-' . now()->timestamp;
                    if (!is_dir(storage_path("app/public/images/posts"))){
                        mkdir(storage_path("app/public/images/posts"), 0777, true);
                    }

                    $img_width = config("image.posts.default.width");
                    $img_height = config("image.posts.default.height");

                    $img = Image::make($file)->fit($img_width, $img_height, function($constraint) {
                        $constraint->aspectRatio();
                    })->setDriver(new \Intervention\Image\Gd\Driver);

                    // convert to webp
                    $img->encode('webp', 100);

                    $img_name = time() . '-'. pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME) . '.webp';

                    $img_name = preg_replace('/[^A-Za-z0-9\-\.]/', '', $img_name);
                    /* save in storage with folder */

                    $img->save(storage_path("app/public/images/posts/".$img_name));

                    // save new image

                    ImagePost::create([
                        'post_id' => $post_id,
                        'path' => "images/posts/".$img_name,
                    ]);

                }
            }
        }
    }

    public function saveProfil($image, $path = 'public')
    {
        if(!$image)
        {
            return null;
        }

        $filename = time().'.png';
        // save image
        Storage::disk($path)->put($filename, base64_decode($image));

        return "images/$path/$filename";
    }
}
