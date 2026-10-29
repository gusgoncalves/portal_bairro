<?php
use CodeIgniter\Router\RouteCollection;
/** @var RouteCollection $routes */
$routes->setAutoRoute(false);
$routes->get('/', 'Page::index');
$routes->get('p/(:segment)', 'Page::index/$1');
$routes->get('media/(:num)', 'Page::media/$1');
$routes->get('revision-media/(:num)', 'Page::revisionMedia/$1');
$routes->match(['GET','POST','PUT','DELETE'], 'api/(:any)', 'Api::handle/$1');
foreach (['gestor','gestor/(:any)','anunciantes','anunciantes/(:any)','admin','admin/(:any)','conta','servicos','profissional/(:num)','anunciar','como-funciona'] as $route) $routes->get($route,'Page::index');
