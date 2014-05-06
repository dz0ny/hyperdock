module DockerApiStubs
  def stub_docker_request meth, url, options={}
    default_request_headers = {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}
    defaults = { :headers => default_request_headers }
    stub_request(meth, url).with(defaults.merge(options))
  end

  def stub_get_info model, opts={success: true}, data=nil
    ok = opts[:success]
    if model.is_a? Container
      data = (data ? data : {"Image" => "somesha1"})
      stub_docker_request(:get, "#{model.host.docker_url}/containers/#{model.instance_id}/json").to_return({
        :status => (ok ? 200 : 500),
        :body => ( ok ? data : {}).to_json, 
        :headers => { "Content-Type" => "application/json" }
      })
    elsif model.is_a? Host
      data = (data ? data : {"Containers" => 0})
      stub_docker_request(:get, "#{model.docker_url}/info").to_return({
        :status => (ok ? 200 : 500),
        :body => ( ok ? data : {}).to_json, 
        :headers => { "Content-Type" => "application/json" }
      })
    end
  end

  def stub_docker_pull host, image
    stub_docker_request(:post, "#{host.docker_url}/images/create", {
      :body => "fromImage=#{image.docker_index}"
    }).to_return({
      :status => 200,
      :body => %{
        {"status":"Pulling..."}
        {"status":"Pulling", "progress":"1 B/ 100 B", "progressDetail":{"current":1, "total":100}}
        {"error":"Invalid..."}
      },
      :headers => { "Content-Type" => "application/json" }
    })
  end

  def stub_docker_run host, image
    stub_docker_request(:post, "#{host.docker_url}/containers/create", {
      headers: { "Content-Type" => "application/json" }
    }).to_return({
      :status => 200,
      :body => '{"Id":"e90e34656806", "Warnings":[]}',
      :headers => { "Content-Type" => "application/json" }
    })
  end

  def stub_docker_start container, config
    stub_docker_request(:post, "#{container.host.docker_url}/containers/#{container.instance_id}/start", {
      headers: { "Content-Type" => "application/json" },
        body: config
    }).to_return({
      :status => 200,
      :body => '{"Id":"e90e34656806", "Warnings":[]}',
      :headers => { "Content-Type" => "application/json" }
    })
  end

  def stub_docker_stop container
    stub_docker_request(:post, "#{container.host.docker_url}/containers/#{container.instance_id}/stop?t=0").
      to_return({
      :status => 200,
      :body => 'OK'
    })
  end

  def stub_docker_rm container
    stub_docker_request(:delete, "#{container.host.docker_url}/containers/#{container.instance_id}?v=1&force=1").
      to_return({
      :status => 200,
      :body => 'OK'
    })
  end
end
