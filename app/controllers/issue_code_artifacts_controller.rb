class IssueCodeArtifactsController < ApplicationController
  
  # before_action :authorize, only: [ :get_tag_artifact_metadata ]
  before_action :yetkilendir, only: [ :get_tag_artifact_metadata, :view_issue_code_artifacts ]
  # before_action :yetkilendir, except: [ :view_issue_code_artifacts ]

  def yetkilendir
    current_project = Issue.find(params[:issue_id]).project
    unless User.current.allowed_to?(@_action_name.to_sym, current_project)
      @error_message = "Kullanıcının bu bilgiye erişme yetkisi yok!"
      html_content = render_to_string(
        template: "errors/401",
        layout: false,
      )
      render html: html_content
    end
  end

  def get_tag_artifact_metadata
    puts ">>>>>>>>>> get_tag_artifact_metadata.............."
    issue_id = params[:issue_id]
    changeset_id = params[:changeset_id].to_i
    tag = params[:tag]

    @issue = Issue.find_by_id(issue_id)
    @project = @issue.project
    @changeset = @issue.changesets.find { |cs| cs.id == changeset_id }
    repository_url = @changeset.repository.url

    @jenkins = GitTagArtifacts::Jenkins.get_jenkins_settings
    @vnf_servers = GitTagArtifacts::Jenkins.get_environments_by_arch("VNF")
    @cnf_servers = GitTagArtifacts::Jenkins.get_environments_by_arch("CNF")
    @artifacts_metadata = GitTagArtifacts::Git.tag_artifacts_metadata(repository_url, tag)
    @artifacts = @artifacts_metadata&.dig("distros")&.map { |cs| cs["artifacts"] }&.compact&.flatten || []

    html_content = render_to_string(
      template: "templates/_tab_content_issue_code_artifacts_metadata_install.html.erb",
      layout: false,
    )
    render html: html_content
  end

  # Test senaryolarının execute edilen koşuları bulur ve bu koşuların etiketlerinde geçen
  # paket_adı=versiyon değerini arar. Bulduklarını paketin olduğu test sonuçları olarak görüntüler.

  def view_issue_code_artifacts

    # current_project = Project.find(Issue.find(params[:issue_id])[:project_id])
    # unless User.current.allowed_to?(:view_issue_code_artifacts_tab, current_project)
    #   @error_message = "Kullanıcının bu bilgiye erişme yetkisi yok!"
    #   html_content = render_to_string(
    #     template: "errors/401",
    #     layout: false,
    #   )
    #   return render html: html_content
    # end

    issue_id = params[:issue_id]
    issue = Issue.find(issue_id)
    code_revisions = GitTagArtifacts::Git.findTagsOfCommits(issue.changesets)

    jenkins = GitTagArtifacts::Jenkins.get_jenkins_settings()
    vnf_servers = GitTagArtifacts::Jenkins.get_environments_by_arch("VNF")
    cnf_servers = GitTagArtifacts::Jenkins.get_environments_by_arch("CNF")

    html_content = render_to_string(
      template: "templates/_tab_content_issue_code_artifacts.html.erb",
      # layout: false ile tüm Redmine sayfasının derlenMEmesini sağlarız
      layout: false,
      locals: {
        issue_id: issue_id,
        code_revisions: code_revisions,
        vnf_servers: vnf_servers,
        cnf_servers: cnf_servers,
        jenkins: {
          url: jenkins[:url],
          job: jenkins[:deployment_job_path],
          job_token: jenkins[:deployment_job_token],
        },
      },
    )
    render html: html_content
  end
end
