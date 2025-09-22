#!/bin/bash
# Runpod startup script for NVIDIA AI Virtual Assistant

echo "Starting NVIDIA AI Virtual Assistant on Runpod..."

# Initialize PostgreSQL if not already done
if [ ! -d "/data/postgres/base" ]; then
    echo "Initializing PostgreSQL..."
    mkdir -p /data/postgres
    chown postgres:postgres /data/postgres
    su - postgres -c "/usr/lib/postgresql/14/bin/initdb -D /data/postgres"
    
    # Start PostgreSQL temporarily to create databases
    su - postgres -c "/usr/lib/postgresql/14/bin/pg_ctl -D /data/postgres start"
    sleep 5
    
    # Create necessary databases
    su - postgres -c "createdb postgres"
    su - postgres -c "createdb customer_data"
    
    # Stop PostgreSQL (will be managed by supervisor)
    su - postgres -c "/usr/lib/postgresql/14/bin/pg_ctl -D /data/postgres stop"
fi

# Initialize Milvus directories
mkdir -p /data/milvus/etcd /data/milvus/configs

# Source environment variables if .env file exists
if [ -f /app/.env ]; then
    export $(cat /app/.env | xargs)
fi

# Set default environment variables for Runpod
export NVIDIA_API_KEY=${NVIDIA_API_KEY:-""}
export NGC_API_KEY=${NGC_API_KEY:-""}

# For Runpod, we'll use NVIDIA-hosted endpoints by default
export APP_LLM_MODELNAME=${APP_LLM_MODELNAME:-"meta/llama-3.3-70b-instruct"}
export APP_LLM_MODELENGINE="nvidia-ai-endpoints"
export APP_LLM_SERVERURL=""

export APP_EMBEDDINGS_MODELNAME=${APP_EMBEDDINGS_MODELNAME:-"nvidia/llama-3.2-nv-embedqa-1b-v2"}
export APP_EMBEDDINGS_MODELENGINE="nvidia-ai-endpoints"
export APP_EMBEDDINGS_SERVERURL=""

export APP_RANKING_MODELNAME=${APP_RANKING_MODELNAME:-"nvidia/llama-3.2-nv-rerankqa-1b-v2"}
export APP_RANKING_MODELENGINE="nvidia-ai-endpoints"
export APP_RANKING_SERVERURL=""

# Database configurations
export POSTGRES_USER=${POSTGRES_USER:-postgres}
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}
export POSTGRES_DB=${POSTGRES_DB:-postgres}
export CUSTOMER_DATA_DB=${CUSTOMER_DATA_DB:-customer_data}

# Service URLs for internal communication
export APP_DATABASE_URL="localhost:5432"
export APP_CACHE_URL="localhost:6379"
export APP_VECTORSTORE_URL="http://localhost:19530"
export CANONICAL_RAG_URL="http://localhost:8086"
export STRUCTURED_RAG_URI="http://localhost:8087"
export AGENT_SERVER_URL="http://localhost:8081"
export ANALYTICS_SERVER_URL="http://localhost:8082"

# Start supervisord to manage all services
echo "Starting services with supervisord..."
exec /usr/local/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf