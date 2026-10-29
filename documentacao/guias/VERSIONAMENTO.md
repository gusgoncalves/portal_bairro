# Versionamento

Repositório solicitado: `portal_bairro`, privado, na conta `gusgoncalves`. A criação e o envio remoto dependem da autenticação oficial do GitHub CLI; o resultado só é considerado concluído após verificar o repositório e o commit remoto.

## Uso local neste ambiente

Executar `versionar.bat status`, `versionar.bat add .`, `versionar.bat commit -m "Descrição"` e `versionar.bat log --oneline`.

O executor permite manter os metadados em `storage/versionamento.git`; o script aponta para esse diretório. Em clones normais, usa o `.git` padrão. Preservar a pasta de metadados para manter o histórico local.

## Arquivos privados

Nunca versionar `.env`, credenciais de SMTP/GitHub, banco real, uploads, sessões, logs, backups, ferramentas locais ou a pasta `storage`. O esquema SQL e `.env.example` sem segredos são versionados. Dependências PHP são reinstaladas com `composer install`.

A visibilidade deve permanecer privada até nova instrução do proprietário.
