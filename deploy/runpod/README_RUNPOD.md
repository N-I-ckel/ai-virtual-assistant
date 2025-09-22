# NVIDIA AI Virtual Assistant - Runpod Deployment Guide

このガイドでは、NVIDIA AI Virtual AssistantをRunpodで動かす方法を説明します。

## 概要

このAI仮想アシスタントは以下の機能を提供します：
- カスタマーサービス向けの対話型AI
- 構造化データ（注文履歴など）と非構造化データ（PDFマニュアルなど）の検索
- マルチターン対話のサポート
- 感情分析と会話要約

## Runpodでの制限事項と対応

### GPU メモリの制限
- **問題**: フルスペックの展開には8x H100/A100が必要
- **解決策**: 
  1. NVIDIA APIエンドポイントを使用（デフォルト設定）
  2. より小さいモデルを使用（例：Llama 3 8Bなど）

### Dockerの制限
- **問題**: RunpodではDocker Composeが使えない
- **解決策**: 単一のDockerイメージにすべてのサービスを統合

## デプロイ手順

### 1. 事前準備

#### API キーの取得
以下のAPIキーが必要です：
1. **NVIDIA API Key**: https://build.nvidia.com/ から取得
2. **NGC API Key**: https://ngc.nvidia.com/ から取得（NVAIEライセンスが必要）

### 2. Dockerイメージのビルド

ローカルマシンまたはビルドサーバーで：

```bash
# リポジトリをクローン
git clone <repository-url>
cd <repository-name>

# .envファイルを作成
cp deploy/runpod/runpod-template.env .env
# .envファイルを編集してAPIキーを設定

# Dockerイメージをビルド
docker build -f deploy/runpod/Dockerfile.runpod -t aiva-runpod:latest .

# Docker Hubまたは他のレジストリにプッシュ
docker tag aiva-runpod:latest your-dockerhub-username/aiva-runpod:latest
docker push your-dockerhub-username/aiva-runpod:latest
```

### 3. Runpodでの設定

#### Runpod Templateの作成

1. Runpodダッシュボードにログイン
2. "Templates"セクションに移動
3. "New Template"をクリック
4. 以下の設定を入力：

```yaml
Template Name: NVIDIA AI Virtual Assistant
Container Image: your-dockerhub-username/aiva-runpod:latest
Container Disk: 50 GB
Volume Disk: 100 GB
Volume Mount Path: /data
Expose HTTP Ports: 3001,9000,8888
Expose TCP Ports: 8081,8082,8086,8087,5432,6379,19530
GPU Type Required: RTX 3090, RTX 4090, A5000, またはそれ以上
Environment Variables:
  NVIDIA_API_KEY: your-nvidia-api-key
  NGC_API_KEY: your-ngc-api-key
```

#### GPU設定の推奨事項

使用可能なGPUに応じた設定：

1. **RTX 3080 10GB** (最小構成):
   - NVIDIA APIエンドポイントを使用（ローカルNIMは使用しない）
   - Milvusのみローカルで実行

2. **RTX 3090/4090 24GB**:
   - 埋め込みモデル（1B）をローカルで実行可能
   - LLMはAPIエンドポイントを使用

3. **A5000/A6000 48GB以上**:
   - より大きなモデルをローカルで実行可能
   - 複数のNIMを同時に実行可能

### 4. Pod の起動

1. Runpodで"Deploy"をクリック
2. 作成したテンプレートを選択
3. 適切なGPUを選択
4. "Deploy On-Demand"または"Deploy Spot"を選択

### 5. 初期設定とデータ投入

Podが起動したら：

```bash
# SSHまたはWeb Terminalでポッドに接続

# Jupyter Labにアクセス
# http://[POD_IP]:8888

# データ投入ノートブックを実行
cd /app/notebooks
# ingest_data.ipynb を開いて実行
```

### 6. アクセス方法

サービスへのアクセス：

- **UI**: http://[POD_IP]:3001
- **API Gateway**: http://[POD_IP]:9000
- **Jupyter Lab**: http://[POD_IP]:8888
- **Agent API**: http://[POD_IP]:8081
- **Analytics API**: http://[POD_IP]:8082

## トラブルシューティング

### サービスが起動しない場合

```bash
# ログを確認
tail -f /var/log/supervisor/*.log

# サービスの状態を確認
supervisorctl status

# 特定のサービスを再起動
supervisorctl restart agent
```

### GPUメモリ不足エラー

1. より小さいモデルを使用：
   ```bash
   export APP_LLM_MODELNAME="meta/llama3-8b-instruct"
   ```

2. バッチサイズを調整：
   環境変数で調整可能

### データベース接続エラー

```bash
# PostgreSQLの状態を確認
supervisorctl status postgres
su - postgres -c "psql -l"
```

## パフォーマンス最適化

### 1. モデル選択
- GPU メモリに応じて適切なモデルサイズを選択
- 8B、13B、70Bモデルから選択可能

### 2. キャッシング
- Redisキャッシュを活用して応答速度を向上
- 頻繁にアクセスされるデータは事前にロード

### 3. バッチ処理
- 複数のリクエストをバッチ処理して効率化

## セキュリティ考慮事項

1. **APIキーの管理**:
   - 環境変数でAPIキーを管理
   - Runpodのシークレット機能を使用

2. **ネットワークセキュリティ**:
   - 必要なポートのみを公開
   - VPNまたはプライベートネットワークの使用を検討

3. **データ保護**:
   - センシティブなデータは暗号化
   - 定期的なバックアップ

## コスト最適化

1. **Spot Instances**:
   - 可能な場合はSpotインスタンスを使用
   - 自動再起動の設定

2. **GPU使用率の監視**:
   - nvidia-smiでGPU使用率を確認
   - 必要に応じてスケールアップ/ダウン

3. **モデルの選択**:
   - タスクに適したサイズのモデルを使用
   - 過剰なリソースを避ける

## サポートとリソース

- [NVIDIA NIM Documentation](https://docs.nvidia.com/nim/)
- [Runpod Documentation](https://docs.runpod.io/)
- [LangGraph Documentation](https://python.langchain.com/docs/langgraph)

## 次のステップ

1. カスタムデータの投入
2. プロンプトのカスタマイズ（`src/agent/prompt.yaml`）
3. UIのカスタマイズ
4. 追加のツールやエージェントの実装