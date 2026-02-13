#!/usr/bin/env bash
# Render.comのビルド時に実行されるスクリプト
# bundle install → アセットコンパイル → DBマイグレーションを順に実行する
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
echo "=== DATABASE_URL is set: $([ -n "$DATABASE_URL" ] && echo 'YES' || echo 'NO') ==="
echo "=== Running db:prepare ==="
bundle exec rails db:prepare
echo "=== db:prepare completed ==="
echo "=== Running db:seed ==="
bundle exec rails db:seed
echo "=== db:seed completed ==="
