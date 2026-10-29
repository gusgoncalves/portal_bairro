<?php
namespace App\Libraries;

/** Vocabulário físico português. O contrato JSON da API permanece compatível. */
final class NomesBanco
{
    public static function mapa(): array
    {
        static $mapa;
        return $mapa??=json_decode(file_get_contents(dirname(__DIR__,2).'/database/nomes_banco.json'),true,32,JSON_THROW_ON_ERROR);
    }
    public static function sql(string $sql): string
    {
        $mapa=array_merge(...array_values(self::mapa()));
        // Ignora literais: valores, textos, senhas e JSON nunca são traduzidos.
        $pattern='~\x27(?:\x27\x27|\\\\.|[^\x27\\\\])*\x27|"(?:""|\\\\.|[^"\\\\])*"|`(?:``|[^`])*`|[A-Za-z_][A-Za-z0-9_]*~s';
        return preg_replace_callback($pattern,static function(array $m)use($mapa):string{
            $token=$m[0];
            if($token[0]==="'"||$token[0]==='"')return $token;
            if($token[0]==='`'){$nome=str_replace('``','`',substr($token,1,-1));return '`'.($mapa[strtolower($nome)]??$nome).'`';}
            return $mapa[strtolower($token)]??$token;
        },$sql);
    }
    public static function registro(array $row): array
    {
        $mapa=array_flip(self::mapa()['colunas']);$out=[];
        foreach($row as $key=>$value)$out[$mapa[$key]??$key]=$value;
        return $out;
    }
}
