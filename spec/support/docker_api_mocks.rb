module DockerApiMocks
  def stub_get_info host, ok=true
    default_headers = {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}

    stub_request(:get, "#{host.docker_url}/info").
      with(:headers => default_headers).
      to_return(:status => (ok ? 200 : 500), :body => ( ok ? {
        "Containers" => 11
      } : {}).to_json, :headers => {
        "Content-Type" => "application/json"
      })
  end
end
