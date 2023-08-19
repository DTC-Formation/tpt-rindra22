<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Support\Str;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function search(Request $request)
    {
        $query = $request->input('query');
        $query = Str::lower($query);

        $results = [];

        if ($query) {
            $results = Post::where(function ($q) use ($query) {
                $q->where('title', 'LIKE', "%$query%")
                  ->orWhere('description', 'LIKE', "%$query%");
            })
            ->with([
                'user:id,name,image',
                'likes' => function ($like) {
                    $like->where('user_id', auth()->user()->id)
                         ->select('id', 'user_id', 'post_id');
                },
                'imagePosts:id,post_id,path',
            ])
            ->withCount('comments', 'likes', 'imagePosts')
            ->get();
        }

        return response()->json(
            ['results' => $results],
            200
        );
    }
}
