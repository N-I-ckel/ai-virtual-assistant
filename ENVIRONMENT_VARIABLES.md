# Environment Variables Reference

本ドキュメントは、AI Virtual Assistantで要求されている全ての環境変数とそれに関連するサービス/APIをリストアップしています。

## 必須APIキー (Required API Keys)

### NVIDIA_API_KEY 🔑
- **サービス**: NVIDIA Inference Microservices (NIM)
- **取得先**: [NVIDIA Build](https://build.nvidia.com/explore/discover) または [NVIDIA NGC](https://ngc.nvidia.com/)
- **形式**: `nvapi-` で始まる文字列
- **用途**: LLM推論、埋め込み生成、ランキング処理

### NGC_API_KEY 🔑  
- **サービス**: NVIDIA GPU Cloud (NGC)
- **取得先**: [NVIDIA NGC](https://ngc.nvidia.com/)
- **用途**: NGCレジストリからのDockerイメージ取得、NIMサービス認証

## モデル設定 (Model Configuration)

| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `APP_LLM_MODELNAME` | `meta/llama-3.3-70b-instruct` | 使用するLLMモデル名 |
| `APP_LLM_SERVERURL` | `""` | LLMサーバーURL (空=NVIDIA hosted API使用) |
| `APP_EMBEDDINGS_MODELNAME` | `nvidia/llama-3.2-nv-embedqa-1b-v2` | 埋め込みモデル名 |
| `APP_EMBEDDINGS_SERVERURL` | `""` | 埋め込みサーバーURL |
| `APP_RANKING_MODELNAME` | `nvidia/llama-3.2-nv-rerankqa-1b-v2` | ランキングモデル名 |
| `APP_RANKING_SERVERURL` | `""` | ランキングサーバーURL |

## データベース設定 (Database Configuration)

### PostgreSQL
| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `POSTGRES_USER` | `postgres` | PostgreSQLユーザー名 |
| `POSTGRES_PASSWORD` | `password` | PostgreSQLパスワード |
| `POSTGRES_DB` | `postgres` | データベース名 |
| `CUSTOMER_DATA_DB` | `customer_data` | 顧客データ専用DB名 |
| `APP_DATABASE_URL` | `postgres:5432` | データベース接続URL |

### Redis Cache
| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `APP_CACHE_NAME` | `redis` | キャッシュ種別 |
| `APP_CACHE_URL` | `redis:6379` | Redis接続URL |
| `REDIS_SESSION_EXPIRY` | `12` | セッション有効期限(時間) |

## ベクターストア設定 (Vector Store Configuration)

| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `APP_VECTORSTORE_NAME` | `milvus` | ベクターDB種別 |
| `APP_VECTORSTORE_URL` | `http://milvus:19530` | MilvusサーバーURL |
| `COLLECTION_NAME` | `unstructured_data` | ベクターコレクション名 |

## サービスURL設定 (Service URLs)

| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `AGENT_SERVER_URL` | `http://agent-chain-server:8081` | エージェントサービス |
| `ANALYTICS_SERVER_URL` | `http://analytics-server:8081` | 分析サービス |
| `CANONICAL_RAG_URL` | `http://unstructured-retriever:8081` | 非構造化検索 |
| `STRUCTURED_RAG_URI` | `http://structured-retriever:8081` | 構造化検索 |

## システム設定 (System Configuration)

### ログ・デバッグ
| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `LOGLEVEL` | `INFO` | ログレベル (DEBUG/INFO/WARN/ERROR) |
| `GRAPH_RECURSION_LIMIT` | `20` | グラフ処理の再帰制限 |
| `GRAPH_TIMEOUT_IN_SEC` | `20` | グラフ処理タイムアウト(秒) |

### GPU設定
| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `LLM_MS_GPU_ID` | `0,1,2,3` | LLM用GPU ID |
| `EMBEDDING_MS_GPU_ID` | `4` | 埋め込み用GPU ID |
| `RANKING_MS_GPU_ID` | `5` | ランキング用GPU ID |
| `VECTORSTORE_GPU_DEVICE_ID` | `0` | ベクターDB用GPU ID |

### 検索設定
| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `APP_RETRIEVER_TOPK` | `4` | 検索結果上位K件 |
| `APP_RETRIEVER_SCORETHRESHOLD` | `0.25` | 検索スコア閾値 |
| `VECTOR_DB_TOPK` | `20` | ベクターDB検索上位K件 |

### 返品ポリシー設定
| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `RETURN_WINDOW_CURRENT_DATE` | `2024-10-23` | 返品基準日 |
| `RETURN_WINDOW_THRESHOLD_DAYS` | `30` | 返品可能日数 |

## デプロイメント設定 (Deployment Configuration)

| 変数名 | デフォルト値 | 説明 |
|--------|------------|------|
| `MODEL_DIRECTORY` | `~/.cache/models/` | モデルキャッシュディレクトリ |
| `USERID` | `1000:1000` | コンテナ実行ユーザーID |
| `REQUEST_TIMEOUT` | `320` | リクエストタイムアウト(秒) |

## 使用サービス・API一覧

1. **NVIDIA Build** - LLM API提供
2. **NVIDIA NGC** - GPU Cloud、コンテナレジストリ
3. **PostgreSQL** - 関係データベース
4. **Redis** - インメモリキャッシュ
5. **Milvus** - ベクターデータベース
6. **NVIDIA NIM Services**:
   - LLM Inference Microservice
   - Embedding Microservice
   - Ranking Microservice

## セットアップ例

```bash
# 必須APIキーの設定
export NVIDIA_API_KEY="nvapi-xxxxxxxxxx"
export NGC_API_KEY="your-ngc-api-key"

# .envファイル作成
cat <<EOF > .env
NVIDIA_API_KEY="your-nvidia-api-key"
NGC_API_KEY="your-ngc-api-key"
EOF
```

詳細な設定方法については、[README.md](./README.md)の「Getting started」セクションを参照してください。