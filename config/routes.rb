Rails.application.routes.draw do
  
    # Issue Code Artifacts rotası
    get "/#{$NAME_CODE_ARTIFACTS}/issues/:issue_id/tab/code_artifacts", to: "issue_code_artifacts#view_issue_code_artifacts"
    get "/#{$NAME_CODE_ARTIFACTS}/issues/:issue_id/tab/code_artifacts/changesets/:changeset_id/tags", to: "issue_code_artifacts#get_tag_artifact_metadata"

    # Jenkins Scriptler API rotası
    get "#{$NAME_CODE_ARTIFACTS}/environments", to: "jenkins_scriptler_api#get_environments"
  
  end
  