# Google Test Playground

## テストに使ったファイル

- https://github.com/google/googletest/tree/main/googletest/samples


## 実行

- http://172.18.28.61/gitlab/docker/google-test-playground

からソースコードをダウンロード。（ユーザ登録していないとgit cloneできない）

```
docker compose up
```

これで結果がカレントディレクトリに出来上がるので

- ./build/test_detail.html
- ./build/coverage_html/index.html 

を開きます。

#### docker image 消去（後始末）

```
docker compose --rmi all
```

## GitLab CI/CD

.gitlab-ci.yml に動作レシピを書いておけばコミット時に実行される。

### GitHub Actions

.github/workflows/test.yml に動作レシピを書いておけばコミット時に実行される。
