## Exportação de dados do Para Pesquisa
Para que as informações possam ser utilizadas com sistema externos de análise de dados
e de Business Intelligence, o Para Pesquisa fornece uma ferramenta para exportar os dados
em CSV com IDs que podem ser utilizados para realizar operações de JOINs nestes sistemas.

Usuário que possuem permissão de administrador dentro do sistema para pesquisa podem encontrar
a opção que leva a ferramenta de exportação no menu direito, logo abaixo do perfil do usuário conectado.

Na tela de exportação é possível iniciar uma nova exportação de dados para cada um dos recursos
apresentados neste documento, além de ser possível visualizar as últimas exportações bem sucedidadas e baixar os arquivos CSVs resultantes.

**Note**:

* Os dados são exportados em UTF-8.
* Apenas a última exportação para cada recurso é disponibilizada.
* Após iniciado a exportação, **não** é necessário manter o navegador aberto, a exportação é gerenciada pelo servidor da aplicação.
* A palavra "submissão" e "pesquisa" são equivalentes para fins deste documento.

## Recursos

Dentro da ferramenta é possível exportar os seguintes recursos:

### Usuários
Ao selecionar a aba "Usuários" na tela de exportação é possível selecionar um dos três
grupos de usuários (pesquisador, administrador, coordenador) ou "todos".

Este arquivo conterá as informações de cada usuário para o grupo selecionado. O campo senha não é disponibilizado pois a aplicação mantem essa informação encriptada por motivos de segurança.

Se selecionado "Incluir cabeçalho" a primeira linha do arquivo CSV conterá o nome da coluna
encontrada naquele posição do arquivo.

O arquivo exportado possuí o nome em formato `users_<timestamp unix do momento da exportação>.csv`.

#### Estrutura

Os seguintes campos se encontram no arquivo de exportação de usuário, na ordem exibida a baixo:

* **user_id** - (int) O ID do usuário desta linha. Pode ser cruzado com o arquivo de exportação de pesquisas (`submissions_<timestamp de exportação>.csv`).
* **Nome** - (string) O nome completo do usuário.
* **Nome de usuário** - (string) O nome de usuário escolhido para entrar no sistema e aplicativo com este usuário.
* **E-mail** - (string) O e-mail do usuário. Pode ser vazio.
* **Data de cadastrado** - (datetime) O dia que este usuário foi criado no sistema em formato ISO 8601.
* **Cargo** - Um dos três grupos de usuário: `Pesquisador`, `Coordenador` ou `Administrador`.

### Questionários

A aba "Questionários" permite que os dados básicos de cada questionário possa ser exportado,
inclusive o `form_id` que pode ser utilizado para distinguir a origem de cada pesquisa.

Se selecionado "Incluir cabeçalho" a primeira linha do arquivo CSV conterá o nome da coluna
encontrada naquele posição do arquivo.

O arquivo exportado possuí o nome em formato `forms_<timestamp unix do momento da exportação>.csv`.

#### Estrutura

Os seguintes campos se encontram no arquivo de exportação de questionários, na ordem exibida a baixo:

* **form_id** - (int) O ID do formulário desta linha. Pode ser cruzado com o arquivo de exportação de pesquisas (`submissions_<timestamp de exportação>.csv`).
* **Título** - (string) O nome dado ao formulário.
* **Subtítulo** - (string) Breve texto sumarizando os objetivos do questionário. Pode ser vazio.
* **Data de criação** - (datetime) O dia que este formulário foi criado no sistema em formato ISO 8601.

### Campos

A aba "Campos" permite a exportação de todos os campos cadastrados, em todos os formulários da aplicação.
Através dele é possível cruzar respostas com questionários para realizar cálculos estatísticos através do campo `form_id` e do campo `field_id`.

Se selecionado "Incluir cabeçalho" a primeira linha do arquivo CSV conterá o nome da coluna
encontrada naquele posição do arquivo.

O arquivo exportado possuí o nome em formato `fields_<timestamp unix do momento da exportação>.csv`.

#### Estrutura

Os seguintes campos se encontram no arquivo de exportação de campos, na ordem exibida a baixo:

**Nota**: tipos de dados com `[]` podem possuir mais de uma resposta.

* **field_id** - (int) O ID do campo que esta linha representa. Pode ser cruzado com o arquivo de exportação de respostas (`answers_<timestamp de exportação>.csv`).
* **form_id** - (int) O ID do questionário que este campo pertence. Pode ser cruzado com o arquivo de exportação de questionários (`forms_<timestamp de exportação>.csv`).
* **Título** - (string) A pergunta deste campo.
* **Tipo** - (string) O tipo deste campo. Os seguintes valores são válidos:
    * **TextField** - (string) Campo de texto genérico.
    * **DatetimeField** - (datetime) Campo de data e hora, exportado no formato ISO 8601.
    * **CpfField** - (string) Campo de CPF com validação automática.
    * **CheckboxField** - (string[]) Campo de escolhas múltiplas não ordenado, apresentado ao usuário como uma caixa de seleção para cada resposta cadastrada.
    * **EmailField** - (string) Campo de e-mail com validação automática.
    * **PrivateField** - (string) Campo de texto privado que permite ao entrevistado responder pergunta de texto que não ficará visível ao pesquisador após seu preenchimento.
    * **NumberField** - (int/float) Campo numérico genérico.
    * **OrderedlistField** - (string[]) Campo de ordenação de múltiplas respostas. Permite o pesquisador qualificar a importância de cada item baseado na ordem de cada resposta.
    * **RadioField** - (string) Campo de seleção única com múltiplas respostas.
    * **UrlField** - (string) Campo de texto que permite o preenchimento de URLs validadas automaticamente.
    * **SelectField** - (string) Campo de seleção única com múltiplas respostas.
    * **LabelField** - (string) Campo que permite ao criador do questionário passar informações extras em texto para consulta do pesquisador. Deve ser ignorado para análise.
    * **DinheiroField** - (string) Campo que formata automáticamente o valor inserido para o padrão da moeda real (R$).

### Pesquisas

Cada questionário preenchido pelo pesquisador resulta em uma "Submissão", que pode ser cruzada com o ID do Usuário e do Questionário para fins de análise.
Além disso, cada Resposta está diretamente ligada a uma Submissão, completando o círculo de ligações das tabelas exportadas.

Dentro desta aba é possível selecionar qual o questionário terá as pesquisas exportadas juntamente com um período e o seu estado no sistema (Aprovado, Cancelado, Reagendado, etc).

Se selecionado "Incluir cabeçalho" a primeira linha do arquivo CSV conterá o nome da coluna
encontrada naquele posição do arquivo.

O arquivo exportado possuí o nome em formato `submissions_<timestamp unix do momento da exportação>.csv`.

#### Estrutura

Os seguintes campos se encontram no arquivo de exportação de questionários, na ordem exibida a baixo:

* **submission_id** - (int) O ID que identifica esta submissão. Pode ser cruzado com o arquivo de exportação de respostas (`answers_<timestamp de exportação>.csv`).
* **form_id** - (int) O ID do questionário desta submissão. Pode ser cruzado com o arquivo de exportação de questionários (`forms_<timestamp de exportação>.csv`).
* **user_id** - (int) O ID do usuário que realizou esta submissão. Pode ser cruzado com o arquivo de exportação de usuários (`users_<timestamp de exportação>.csv`).
* **Data de criação** - (datetime) O dia que este formulário foi criado no sistema em formato ISO 8601. Apenas presente caso tenha sido importado (via dados extras).
* **Data de preenchimento** - (datetime) O dia que este formulário foi recebido no sistema em formato ISO 8601.
* **Data de aprovação** - (datetime) O dia que este formulário foi aprovado por um moderador no sistema em formato ISO 8601.

### Respostas

Por fim, as respostas das pesquisas podem ser exportadas na aba "Respostas". Esta aba possuí as mesmas opções de exportação que as submissões (pesquisas).
Cada resposta pode ser cruzada com uma submissão e um campo, através dessas conexões é possível saber qual usuário respondeu a pergunta para cada questionário.

Se selecionado "Incluir cabeçalho" a primeira linha do arquivo CSV conterá o nome da coluna
encontrada naquele posição do arquivo.

O arquivo exportado possuí o nome em formato `answers_<timestamp unix do momento da exportação>.csv`.

#### Estrutura
* **submission_id** - (int) O ID que identifica a pesquisa desta resposta. Pode ser cruzado com o arquivo de exportação de pesquisa (`submissions_<timestamp de exportação>.csv`).
* **field_id** - (int) O ID do campo que esta resposta é direcionada. Pode ser cruzado com o arquivo de exportação de campos (`fields_<timestamp de exportação>.csv`).
* **Resposta** - O valor da resposta feita a submissão e campos presentes nesta linha. O tipo de dado depende do tipo de campo ligado a esta resposta.
* **Ordem** - (int) Para campos que possuem múltiplas respostas e a ordem possuí importância, é necessário ordenar por este campo. Valores mais importantes aparecem primeiro (ordem crescente).