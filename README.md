# tfaction v2: Pull Request に連動する Terraform plan / apply の例

このリポジトリは、[tfaction](https://suzuki-shunsuke.github.io/tfaction/docs/) を使って次の流れを実行する最小構成です。

1. Pull Request を作成・更新すると `terraform plan` を実行する
2. plan の結果を Pull Request にコメントする
3. Pull Request を `main` にマージすると、plan 時に保存された plan file を使って `terraform apply` を実行する
4. apply の結果を元の Pull Request にコメントする

Terraform の対象には `null_resource`、backend には Local Backend を使うため、AWS や Google Cloud の認証情報なしで tfaction の動作を確認できます。

> [!WARNING]
> Local Backend の state は GitHub Actions runner の終了時に失われます。この構成は tfaction の学習用です。実運用では S3 や GCS などの Remote Backend を使用してください。

## ファイル構成

```text
.
├── .github/workflows/
│   ├── apply.yaml              # main へのマージ後に apply
│   ├── test.yaml               # Pull Request で plan
│   └── workflow_call_list.yaml # 変更された root module を検出
├── aqua.yaml            # Terraform のバージョン管理
├── tfaction-root.yaml   # リポジトリ全体の tfaction 設定
└── terraform/
    └── sample/
        ├── main.tf       # サンプルの root module
        └── tfaction.yaml # root module 固有の tfaction 設定
```

## 事前準備

tfaction が Pull Request へのコメント、ラベル追加、lock file のコミットなどを行えるように GitHub App を作成します。

GitHub App に次の Repository permissions を設定してください。

- Actions: Read
- Contents: Write
- Pull requests: Write

Webhook は不要なので無効にできます。作成した App をこのリポジトリへインストールし、次の値をリポジトリに登録します。

| 種類 | 名前 | 値 |
| --- | --- | --- |
| Actions variable | `APP_ID` | GitHub App の App ID |
| Actions secret | `PRIVATE_KEY` | GitHub App から発行した秘密鍵（PEM） |

設定場所はリポジトリの **Settings → Secrets and variables → Actions** です。

## 動作確認

1. この構成を `main` ブランチへ push します。
2. 作業ブランチを作り、たとえば `terraform/sample/main.tf` の `triggers` の値を変更します。
3. Pull Request を作成します。
4. `list-targets` が変更された root module を検出し、`test` workflow が対象ごとに plan を実行して結果を Pull Request にコメントします。
5. 最初の実行では `.terraform.lock.hcl` を追加するコミットが作られる場合があります。その後の plan が成功したことを確認します。
6. Pull Request をマージします。
7. `apply` workflow が保存済みの plan file を使って apply し、結果を Pull Request にコメントします。

## 実運用へ持っていくとき

- Local Backend を Remote Backend に変更する
- GitHub Actions の OIDC でクラウドの plan 用・apply 用ロールを分離する
- `suzuki-shunsuke/tfaction` や他の Actions を commit SHA で固定する
- GitHub Environment の保護ルールで apply に承認を要求する
- Renovate などで Action、Terraform、aqua registry のバージョンを更新する

この例は tfaction v2.0.3 の構成に合わせています。
