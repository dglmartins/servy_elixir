defmodule Servy.Api.JobsController do
  def create(
        conv,
        %{"name" => name, "email" => email, "resume" => resume, "github" => github} = params
      ) do
    %{
      conv
      | status: 201,
        resp_body:
          "Created an application for #{name}, #{email} whose link to resume is #{resume} and linke to github is #{
            github
          }"
    }
  end
end
