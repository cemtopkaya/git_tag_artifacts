# encoding: utf-8

require "redmine"

$NAME_CODE_ARTIFACTS = :ulak_git_tag_artifacts_v1
$PLUGIN_NAME_CODE_ARTIFACTS = :plugin_ulak_git_tag_artifacts_v1

def init
  begin
    Dir::foreach(File.join(File.dirname(__FILE__), "lib")) do |file|
      next unless /\.rb$/ =~ file
      require_dependency file
    end
  rescue LoadError => le
    puts "--- Error: init.rb içinde store.rb yüklenirken hata: #{le.message}"
  end
end

if Rails::VERSION::MAJOR >= 5
  ActiveSupport::Reloader.to_prepare do
    init
  end
elsif Rails::VERSION::MAJOR >= 3
  ActionDispatch::Callbacks.to_prepare do
    init
  end
else
  Dispatcher.to_prepare :redmine_closed_date do
    init
  end
end

Redmine::Plugin.register $NAME_CODE_ARTIFACTS do
  name "Git Tag Artifacts"
  author "Cem Topkaya"
  description "This plugin brings artifacts from git tags contains associated revisions"
  version "1.0.0"
  url "https://github.com/cemtopkaya/git_tag_artifacts"
  author_url "https://cemtopkaya.com"
  requires_redmine :version_or_higher => "5.0.0"

  PLUGIN_ROOT_CODE_ARTIFACTS = Pathname.new(__FILE__).join("..").realpath.to_s
   yaml_settings = YAML::load(File.open(File.join(PLUGIN_ROOT_CODE_ARTIFACTS + "/config", "settings.yml")))

  settings :default => {
    "jenkins_url" => yaml_settings["jenkins_url"],
    "jenkins_username" => yaml_settings["jenkins_username"],
    "jenkins_token" => yaml_settings["jenkins_token"],
    "deployment_job_path" => yaml_settings["deployment_job_path"],
    "deployment_job_token" => yaml_settings["deployment_job_token"],
  }, partial: "settings/git_tag_artifacts_settings.html"

  project_module $NAME_CODE_ARTIFACTS do
    permission :view_deploy_artifact_button, {}
    # Code Artifacts sekme başlığını
    permission :view_issue_code_artifacts_tab, {}
    # Code Artifacts sekme içeriğini göster
    permission :view_issue_code_artifacts, { issue_code_artifacts: :view_issue_code_artifacts }
    # Code Artifacts etiketlerinin bilgilerini çek
    permission :get_tag_artifact_metadata, { issue_code_artifacts: :get_tag_artifact_metadata }
  end
end

puts Setting[$PLUGIN_NAME_CODE_ARTIFACTS]
