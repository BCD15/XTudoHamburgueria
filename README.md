# 🍔 Sistema de Gerenciamento Hamburgueria XTudo

## 📌 Descrição do Projeto

O **Hamburgueria XTudo** é um sistema desenvolvido em **Progress 4GL/OpenEdge** para gerenciar os processos de uma hamburgueria, incluindo **cadastro de clientes, produtos, cidades, pedidos e itens**, além de relatórios e exportação de dados.

O sistema visa facilitar o controle administrativo e financeiro, garantindo integridade dos dados e exportações para integração com sistemas da franqueadora.

## ⚙️ Funcionalidades

* **Menu principal** para acesso aos cadastros e relatórios.
* **Cadastro de Cidades** com bloqueio de exclusão se vinculada a clientes.
* **Cadastro de Clientes** com verificação de cidade válida.
* **Cadastro de Produtos** com bloqueio de exclusão se vinculados a pedidos.
* **Cadastro de Pedidos e Itens** com:

  * Validação de cliente e produto.
  * Exclusão em cascata de itens ao excluir um pedido.
* **Botões padrão de navegação e edição**:

  * `<<` Primeiro registro
  * `<` Registro anterior
  * `>` Próximo registro
  * `>>` Último registro
  * `Adicionar`, `Modificar`, `Eliminar`, `Salvar`, `Cancelar`, `Exportar`, `Sair`
* **Exportação de dados** para `.JSON` e `.CSV`.
* **Relatórios**:

  * Lista de clientes
  * Pedidos por cliente, com itens, quantidades, valores e totais.

## 🗄 Estrutura do Banco de Dados

O banco de dados é criado em:

```
c:\dados\xtudo.db
```

**Tabelas:**

* **Cidades** (`CodCidade`, `NomCidade`, `CodUF`)
* **Clientes** (`CodCliente`, `NomCliente`, `CodEndereco`, `CodCidade`, `Observacao`)
* **Produtos** (`CodProduto`, `NomProduto`, `ValProduto`)
* **Pedidos** (`CodPedido`, `CodCliente`, `DatPedido`, `ValPedido`, `Observacao`)
* **Itens** (`CodPedido`, `CodItem`, `CodProduto`, `NumQuantidade`, `ValTotal`)

**Sequências:**

* `seqCidade`
* `seqCliente`
* `seqPedido`
* `seqProduto`

## ▶️ Como Executar o Projeto

### 📌 Pré-requisitos

* **Progress OpenEdge** instalado e configurado.
* Banco de dados `xtudo.db` na pasta `c:\dados\`.
* Fontes do projeto (`.p`) no diretório de execução.

### 📂 Arquivos Necessários

* **Fontes** do sistema (`.p`).
* **Banco de dados** (`xtudo.db`, `.df` e `.d`).
* **Arquivo README.md** (este documento).

### 🔧 Passo a Passo

1. **Clonar o repositório** ou extrair o `.zip` enviado:

   ```bash
   git clone https://github.com/seuusuario/hamburgueria-xtudo.git
   ```
2. **Copiar o banco de dados** para `c:\dados\xtudo.db`.
3. **Abrir o Progress/OpenEdge**.
4. **Conectar ao banco de dados**:

   ```
   CONNECT c:\dados\xtudo.db -1
   ```
5. **Executar o programa principal**:

   * Localize e abra o arquivo inicial (`menu.p` ou equivalente).
   * Rode a aplicação.
6. **Utilizar o menu** para realizar cadastros, emitir relatórios e exportar dados.

## 🔗 Exportação de Dados

O sistema gera:

* **Arquivo JSON** com pedidos, itens e valores.
* **Arquivo CSV** para dados de tabelas.

## 🎥 Vídeo Demonstrativo

O vídeo com a apresentação do sistema está disponível em:
`link_do_video_aqui`
