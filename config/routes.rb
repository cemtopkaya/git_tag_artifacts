Rails.application.routes.draw do
    # Diğer rotalar burada
  
    # Kiwi API rotaları
    namespace :ulak_test do
      get "tests", to: "issue_test#get_tests"
      get "tests/sync", to: "kiwi_api#sync_kiwi_test_cases"
    end
  
    # Issue Code Artifacts rotası
    get "/ulak_test/issues/:issue_id/tab/code_artifacts", to: "issue_code_artifacts#view_issue_code_artifacts"
    # get "/ulak_test/tab/code_artifacts/issues/:issue_id/changesets/:changeset_id/tags/:tag", to: "issue_code_artifacts#get_tag_artifact_metadata"
    get "/ulak_test/issues/:issue_id/tab/code_artifacts/changesets/:changeset_id/tags", to: "issue_code_artifacts#get_tag_artifact_metadata"

    
    # Jenkins Scriptler API rotası
    get "ulak_test/environments", to: "jenkins_scriptler_api#get_environments"
  
  end
  