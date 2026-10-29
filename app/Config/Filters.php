<?php
namespace Config;
use CodeIgniter\Config\Filters as BaseFilters;
class Filters extends BaseFilters
{
    public array $aliases = ['secureheaders'=>\CodeIgniter\Filters\SecureHeaders::class];
    public array $required = ['before'=>[], 'after'=>[]];
    public array $globals = ['before'=>[], 'after'=>['secureheaders']];
    public array $methods = [];
    public array $filters = [];
}
