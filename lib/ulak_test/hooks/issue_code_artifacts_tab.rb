require "yaml"
require "net/http"
require "json"

module UlakTest
  module Hooks
    class IssueCodeArtifactsTab < Redmine::Hook::ViewListener
      def view_issues_show_details_bottom(context = {})
        Rails.logger.info(">>> IssueAssociatedRevision.view_issues_show_details_bottom <<<<")
        issue = context[:issue]
        associated_revisions = Git.findTagsOfCommits(issue.changesets)

        hook_caller = context[:hook_caller]
        controller = hook_caller.is_a?(ActionController::Base) ? hook_caller : hook_caller.controller

        output = controller.send(:render_to_string, {
          # Code Artifact sekmesini oluşturacak JS kodlarını "issues/tabs/tab_issue_code_artifacts" dosyası içerir  
          partial: "issues/tabs/tab_issue_code_artifacts",
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
