require "yaml"
require "net/http"
require "json"

module GitTagArtifacts
  module Hooks
    class IssueCodeArtifactsTab < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        Rails.logger.info(">>> IssueAssociatedRevision.view_issues_show_details_bottom <<<<")

        issue = context[:issue]
        current_project = issue.project
        is_code_artifacts_module_enabled = current_project.module_enabled?($NAME_CODE_ARTIFACTS)

        unless is_code_artifacts_module_enabled
          Rails.logger.info(">>> Code Artifacts module is not enabled in the project #{current_project.name}, so the Code Artifacts tab will not be created... !!!! <<<<")
          return
        end

        # Check if the user is authorized to view the plugin.
        unless User.current.allowed_to?(:view_issue_code_artifacts_tab, current_project)
          # The user is not authorized to view the plugin.
          Rails.logger.info(">>> #{User.current.login} does not have permission to view the Code Artifacts tab, so this tab will not be created... !!!! <<<<")
          return
        end

        issue = context[:issue]
        associated_revisions = GitTagArtifacts::Git.findTagsOfCommits(issue.changesets)

        hook_caller = context[:hook_caller]
        controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller

        output = controller.send(:render_to_string, {
          # Code Artifact sekmesini oluşturacak JS kodlarını "issues/tabs/tab_issue_code_artifacts" dosyası içerir
          partial: "hooks/issues/tabs/tab_issue_code_artifacts",
          locals: {
            issue_id: issue.id,
            changesets: associated_revisions,
          },
        })

        output
      end
    end # < class IssueAssociatedRevision
  end # < module Hook
end # < module UlakTest
