Para Pesquisa
=============

**Note**: An english version of this guide is also available in the `README-en.md` file.

Para Pesquisa é um software livre para criação de formulários desenvolvida para
empresas e instituições interessadas em aplicar pesquisas em campo, nas áreas de
saúde, educação, moradia, meio ambiente, entre outras. Funciona com um
aplicativo instalado em tablet com sistema operacional Android. Os formulários
preenchidos são transmitidos pela internet e armazenados em plataforma web.
Nessa plataforma, gestores podem criar novos formulários e acompanhar o
desenvolvimento das pesquisas.

O sistema conta com um painel administrativo amigável e moderno para criação de
formulários no qual administradores e responsáveis podem criar pesquisas em
poucos minutos. Possui uma interface de visualização das pesquisas realizadas,
pendentes, fluxo de aprovação de pesquisas, criação de usuários pesquisadores e
coordenadores e atribuição de cotas de pesquisa. Pesquisadores e coordenadores
podem baixar o aplicativo em tablets de quaisquer marcas, modelos e tamanhos com
sistema Android e aplicar as pesquisas usando uma interface gráfica amigável.

## Instalação

O servidor que hospeda o painel administrativo e gerencia a sincronização dos
 formulários foi desenvolvido em Ruby on Rails. A seguinte stack é
 recomendada para o deploy desta aplicação:

 * Ruby
 * PostgreSQL
 * Unicorn
 * nginx
 * Redis

Existem diversas outras estratégias que utilizam outros softwares para deploy
disponíveis, consulte a [documentação oficial](http://rubyonrails.org/deploy)
 do Ruby on Rails para mais informações.

### Instalação em servidor Ubuntu 12.04

A seguir demonstramos a instalação da aplicação em um servidor Ubuntu
utilizando nginx como proxy reverso configurado para rodar no mesmo servidor.
 Em situações de deploys reais é necessário considerar o uso de load
 balancing para a camada HTTP, clusterização para o [Redis](http://redis
 .io/topics/cluster-tutorial) e [PostgreSQL](http://wiki.postgresql
 .org/wiki/Replication,_Clustering,_and_Connection_Pooling).

É assumido uma instalação nova, sem nenhum pacote extra instalado,
logado em usuário não previlegiado.

#### Instalando ruby 2.0

Atualize os repositórios:

    sudo apt-get -y update

Instale as dependências para compilação do ruby:

    sudo apt-get -y install wget build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libxml2 libxml2-dev libxslt1-dev

Baixe e prepare o código fonte para build:

    cd /tmp
    wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p353.tar.gz
    tar -xvzf ruby-2.0.0-p353.tar.gz
    cd ruby-2.0.0-p353/
    ./configure --prefix=/usr/local

Compile:

    make

Instale:

    sudo make install

#### Instalando Redis

Instale o redis pelo repositório:

    sudo apt-get -y install redis-server

Se necessário altere o tempo que o Redis demora para realizar o flush dos
dados ao sistema de arquivos para algo mais razoável. Os dados salvos no
Redis são primariamente caches e informações de exportações em andamento,
caso haja perca de informação nele os clientes precisão atualizar as
informações no tablet antes de sincronizar alterações.

#### Instalando PostgreSQL

É recomendado instalar uma versão recente do banco de dados,
primeiramente adicione o repositório do postgres ao sources.list:

    sudo su -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list'
    sudo rm /var/lib/apt/lists/* -rf

Após isso atualize e instale:

    sudo apt-get -y update
    sudo apt-get -y --force-yes install postgresql-9.3 postgresql-server-dev-9.3

#### Instale o Git

    sudo apt-get -y install git-core

#### Crie o usuário para rodar a aplicação:

    sudo adduser --disabled-password --gecos "" para_pesquisa

#### Baixe a API

    cd /home/para_pesquisa
    git clone https://github.com/LaFabbrica/para-pesquisa-servidor.git

#### Instalando o bundler

    cd para-pesquisa-servidor
    sudo gem install bundler

#### Instalando as dependências

    sudo bundle install --without development test --path vendor/bundle

#### Crie o banco de dados

    sudo su - postgres -c "createdb para_pesquisa"

#### Crie o usuário com permissão para acesso ao banco de dados

    sudo su - postgres -c "psql -c \"CREATE USER para_pesquisa WITH PASSWORD 'TROQUE_A_SENHA';\""
    sudo su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE para_pesquisa to para_pesquisa;\""

#### Habilite autenticação via password no PostgreSQL

    sudo sed -i 's/^\(local\s*all\s*all\s*\)\(peer\)/\1md5/' /etc/postgresql/9.3/main/pg_hba.conf
    sudo service postgresql restart

#### Altere a configuração do banco de dados da aplicação

Na pasta onde clonou o repositório altere o arquivo config/database.yml com a
senha que você inseriu no comando anterior.

#### Baixe o nodejs para executar os comandos de criação do banco e dos usuários base:

    sudo apt-get install nodejs

#### Crie a estrutura no banco de dados

    bundle exec rake db:migrate

#### Crie o usuário administrador

    bundle exec rake db:seed

#### Instale o aplicativo no upstart

Para rodar o unicorn como daemon, instale o unicornherder:

    sudo apt-get install -y python-dev python-pip
    sudo pip install unicornherder

Crie o arquivo de configuração para que o aplicativo seja controlado pelo
upstart em `/etc/init/para-pesquisa.conf`:

    description "Para Pesquisa - API"

    start on runlevel [2345]
    stop on runlevel [!2345]

    respawn
    respawn limit 5 20

    env PORT=8080
    env HOST=127.0.0.1
    
    env AWS_ACCESS_KEY_ID=Sua Access Key do S3
    env AWS_SECRET_ACCESS_KEY=Sua Secret Key do S3
    env AWS_BUCKET=Seu bucket

    setuid para_pesquisa
    setgid para_pesquisa

    chdir /home/para_pesquisa/para-pesquisa-servidor

    exec bundle exec unicornherder -u unicorn -- -o $HOST --port $PORT -c config/unicorn.rb
    
Se você deseja utilizar as funcionalidades de exportação por CSV é necessário 
trocar as chaves do S3 da Amazon em `AWS_ACCESS_KEY_ID` e  `AWS_SECRET_ACCESS_KEY`
também será necessário criar um bucket dentro do S3 e alterar em `AWS_BUCKET`.

Após isso configure as permissões e inicie o serviço:

    sudo chown -R para_pesquisa: /home/para_pesquisa
    sudo service para-pesquisa start

#### Instale o nginx

Ele servirá como buffer para clientes com conexões lentas e disponibilizará os
arquivos estáticos da API e Painel Administrativo.

    sudo apt-get install -y nginx


Para que o nginx seja usado como proxy reverso ao servidor unicorn da API, uma
entrada como a seguinte poderia ser utilizada em `/etc/nginx/sites-enabled/para-pesquisa-servidor`.

      upstream unicorn_server {
       server 127.0.0.1:8080 fail_timeout=0;
       fail_timeout=0;
      }

      server {
        listen 8085;
        client_max_body_size 4G;
        server_name api.meu-para-pesquisa.org.br;
        keepalive_timeout 5;
        large_client_header_buffers 4 32k;

        root /home/para_pesquisa/para-pesquisa-servidor/public;

        location / {
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;
          proxy_redirect off;

          if (!-f $request_filename) {
            proxy_pass http://unicorn_server;
            break;
          }
        }

        error_page 500 502 503 504 /500.html;
        location = /500.html {
          root /home/para_pesquisa/para-pesquisa-servidor/public;
        }
      }

Note `large_client_header_buffers` com o limite de `32k`. Um cabeçalho com timestamps é enviado durante a sincronização e pode ultrapassar o limite padrão de tamanho do nginx.

#### Baixe o painel administrativo

O Painel Administrativo é um aplicativo HTML5 que permite você gerenciar a
sua instalação do Para Pesquisa. É através dele que usuários e formulários são
criados e dados são exportados.

Para gerar uma build que aponta para o seu servidor siga as [instruções do repositório](https://github.com/institutotim/para-pesquisa-painel). 

Após isso basta copiar a pasta `app/dist` para `/home/para_pesquisa/para-pesquisa-painel/app` e criar uma entrada no 
nginx para que sirva os arquivos do painel.
O seguinte exemplo poderia ser utilizado em `/etc/nginx/sites-enabled/para-pesquisa-painel`:

    server {
            listen 80;
            server_name meu-para-pesquisa.org.br;
            root /home/para_pesquisa/para-pesquisa-painel;
            index index.html;
    }
    
Após criar ambos arquivos de configuração no nginx, é necessário reiniciar o serviço, para que as mudanças sejam aplicadas:

    sudo service nginx restart

Por padrão o painel irá tentar conectar na API através do mesmo domínio ao qual ele é acessado, na porta `8085` configurada acima. Caso você deseje trocar a URL da API para o seu domínio e/ou porta realize os seguintes passos:

##### Navegue onde você realizou o download do painel
 
    cd /home/para_pesquisa/para-pesquisa-painel
    
##### Troque a URL padrão pela sua API

Basta trocar `http:\/\/api.exemplo.org.br` no comando abaixo pela URL da sua API. Lembre-se de manter `\/` ao invés de `/` para que o comando interprete o caracter corretamente.

    sed -i '' 's/\(url\: \)\(undefined\)/\1"http:\/\/api.exemplo.org.br"/' app/index.html

## Usuários pré cadastrados
Por padrão, a aplicação está disponibilizada com três usuários para testes:
 *	Tipo: Administrator - nome para login: ‘apiuser’ - password: ‘apipass’;
 *	Tipo: Moderator - nome para login: ‘moduser’ - password: ‘modpass’;
 *	Tipo: Agente - nome para login: ‘agentuser’ - password: ‘agentpass’;

## Exportação de dados
Um documento com instruções para exportação de dados [pode ser encontrado](https://github.com/LaFabbrica/para-pesquisa-servidor/blob/master/docs/Exportacao.md) na pasta `docs` deste repositório.

## Licença
O Para Pesquisa é disponibilizado sobre a licença de código fonte aberto GNU GPL versão 2. Uma cópia pode ser encontrada na integra no arquivo LICENSE deste repositório.
