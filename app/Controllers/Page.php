<?php
namespace App\Controllers;
use App\Models\PortalRepository;

class Page extends BaseController
{
    public function index(...$segments){return $this->response->setHeader('Cache-Control','no-store')->setBody(view('portal'));}
    public function media(int $id)
    {
        try{
            $repo=new PortalRepository();
            $image=$repo->one('SELECT i.*,p.status,p.portal_id,p.advertiser_id FROM publication_images i JOIN publications p ON p.id=i.publication_id JOIN portals t ON t.id=p.portal_id WHERE i.id=? AND t.active=1',[$id]);
            if(!$image)return $this->response->setStatusCode(404);
            if($image['status']!=='published'){
                $session=session();$user=$session->get('user_id')?$repo->one('SELECT id,role,advertiser_id FROM users WHERE id=? AND active=1',[$session->get('user_id')]):null;
                if(!$session->get('last_seen')||time()-(int)$session->get('last_seen')>3600)return $this->response->setStatusCode(404);
                $repo->publication((int)$image['publication_id'],(int)$image['portal_id'],$user);
            }
            $path=\App\Libraries\CatalogService::uploadDirectory().'/'.$image['filename'];
            if(!is_file($path))return $this->response->setStatusCode(404);
            return $this->response->setHeader('Content-Type',$image['mime'])->setHeader('X-Content-Type-Options','nosniff')->setHeader('Cache-Control','private, no-store')->setBody(file_get_contents($path));
        }catch(\Throwable){return $this->response->setStatusCode(404);}
    }
    public function revisionMedia(int $id)
    {
        try{
            $repo=new PortalRepository();$session=session();
            if(!$session->get('last_seen')||time()-(int)$session->get('last_seen')>3600)return $this->response->setStatusCode(404);
            $user=$session->get('user_id')?$repo->one('SELECT id,role,advertiser_id FROM users WHERE id=? AND active=1',[$session->get('user_id')]):null;
            $image=$repo->one('SELECT i.*,r.publication_id,p.portal_id FROM revision_images i JOIN publication_revisions r ON r.id=i.revision_id JOIN publications p ON p.id=r.publication_id JOIN portals t ON t.id=p.portal_id WHERE i.id=? AND t.active=1',[$id]);
            if(!$image)return $this->response->setStatusCode(404);
            $repo->publication((int)$image['publication_id'],(int)$image['portal_id'],$user);
            $path=\App\Libraries\CatalogService::uploadDirectory().'/'.$image['filename'];
            if(!is_file($path))return $this->response->setStatusCode(404);
            return $this->response->setHeader('Content-Type',$image['mime'])->setHeader('X-Content-Type-Options','nosniff')->setHeader('Cache-Control','private, no-store')->setBody(file_get_contents($path));
        }catch(\Throwable){return $this->response->setStatusCode(404);}
    }
}
