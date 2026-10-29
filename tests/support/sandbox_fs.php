<?php
/** Apenas para executar testes no sandbox Windows, cujas consultas de ACL
 * retornam false mesmo quando fopen funciona. Nunca é carregado pela aplicação. */
namespace PortalTest {
    if ((getenv('PORTAL_TEST_DB') || preg_match('/^portal_prd_teste_[a-f0-9]{10}$/D',(string)getenv('database.default.database'))) && !defined('PORTAL_CGI_TEST')) define('PORTAL_CGI_TEST', true);
    foreach (['CI_ENVIRONMENT','PORTAL_TEST_DB','PORTAL_TEST_UPLOAD_PATH','session.savePath','session.cookieName','app.baseURL','database.default.database','portal.defaultSlug','portal.chaveEmails','email.SMTPHost','email.SMTPPort','email.SMTPUser','email.SMTPPass','email.SMTPCrypto','email.fromEmail'] as $key) { if (getenv($key)!==false) { $_ENV[$key]=getenv($key); $_SERVER[$key]=getenv($key); } }
    if (!defined('SUPPORTPATH')) define('SUPPORTPATH', __DIR__.DIRECTORY_SEPARATOR);
    function readable(string $path): bool { $h=@fopen($path,'rb');if(!$h)return false;fclose($h);return true; }
    function writable(string $path): bool {
        $root=realpath(__DIR__.'/../..');$real=realpath($path);
        if(!$real||!str_starts_with($real,$root.DIRECTORY_SEPARATOR))return false;
        if(is_dir($real)){ $name=$real.DIRECTORY_SEPARATOR.'.probe-'.bin2hex(random_bytes(8));$h=@fopen($name,'xb');if(!$h)return false;fclose($h);unlink($name);return true; }
        $h=@fopen($real,'r+b');if(!$h)return false;fclose($h);return true;
    }
}
namespace CodeIgniter\Config { function is_readable($p){return \PortalTest\readable($p);} }
namespace CodeIgniter\Log { function is_writable($p){return \PortalTest\writable($p);} }
namespace CodeIgniter\Session\Handlers { function is_writable($p){return \PortalTest\writable($p);} function is_readable($p){return \PortalTest\readable($p);} }
namespace CodeIgniter\Files { function is_writable($p){return \PortalTest\writable($p);} function is_readable($p){return \PortalTest\readable($p);} }
namespace CodeIgniter\HTTP\Files { function is_writable($p){return \PortalTest\writable($p);} function is_readable($p){return \PortalTest\readable($p);} }
