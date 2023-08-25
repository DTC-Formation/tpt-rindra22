<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ImagePost;
use App\Models\Post;
use App\Traits\SaveImageTrait;
use Illuminate\Http\Request;

class PostController extends Controller
{
    use SaveImageTrait;
    public function index()
    {
        return response([
            'posts' => Post::orderBy('created_at', 'desc')
            ->with(
                [
                    'user:id,name,image',
                    'imagePosts' => function($image){
                        return $image->select('id', 'post_id', 'path')->get();
                    }
                ]
            )
            ->withCount('comments', 'likes','imagePosts')
            ->with('likes', function($like){
                return $like->where('user_id', auth()->user()->id)
                    ->select('id', 'user_id', 'post_id')->get();
            })
            ->get()
        ], 200);
    }

    public function show($id)
    {
        return response([
            'post' => Post::where('id', $id)->withCount('comments', 'likes','imagePosts')->get()
        ], 200);
    }

    public function store(Request $request)
    {
        $attrs = $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
        ]);

        $post = Post::create([
            'title' => $attrs['title'],
            'description' => $attrs['description'],
            'user_id' => auth()->user()->id
        ]);

        $this->save($request->images, 'posts',$post->id);

        return response([
            'message' => 'Post created.',
            'post' => $post,
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $post = Post::find($id);

        if(!$post)
        {
            return response([
                'message' => 'Post not found.'
            ], 403);
        }

        if($post->user_id != auth()->user()->id)
        {
            return response([
                'message' => 'Permission denied.'
            ], 403);
        }


        $attrs = $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
        ]);

        // update image
        if($request->path)
        {
            $this->save($request->path, 'posts',$post->id,true);
        }

        $post->update([
            'title' =>  $attrs['title'],
            'description' => $attrs['description'],
        ]);

        return response([
            'message' => 'Post updated.',
            'post' => $post
        ], 200);
    }

    public function destroy($id)
    {
        $post = Post::find($id);

        if(!$post)
        {
            return response([
                'message' => 'Post not found.'
            ], 403);
        }

        if($post->user_id != auth()->user()->id)
        {
            return response([
                'message' => 'Permission denied.'
            ], 403);
        }

        $post->comments()->delete();
        $post->likes()->delete();
        $post->imagePosts()->delete();
        $post->delete();

        return response([
            'message' => 'Post deleted.'
        ], 200);
    }
}
