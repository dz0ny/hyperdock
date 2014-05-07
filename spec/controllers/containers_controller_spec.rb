require 'spec_helper'

describe ContainersController do
  let(:user) { create(:user) }

  before(:each) do
    @image = create(:image)
    @host = create(:host)
  end

  describe "POST 'create'" do

    describe "unauthorized user" do
      it "redirects to login page" do
        post 'create', container: { name: "Test", image_id: @image.id, region_id: @host.region.id }
        response.should redirect_to new_user_session_path
      end
    end

    describe "authorized user" do
      before { sign_in user }

      it "persists a container for the user" do
        post 'create', container: { name: "Test",  image_id: @image.id, region_id: @host.region.id }
        assigns(:container).user.id.should eq user.id
        response.should redirect_to assigns(:container)
        flash[:notice].should match /success/
      end


      describe "user would exceed container limit" do
        before { user.container_limit = 0 ; user.save }
        it "does not create the container" do
          post 'create', container: { name: "Test",  image_id: @image.id, region_id: @host.region.id }
          user.reload.containers.should be_empty
          response.should redirect_to containers_path
          flash[:alert].should match /limited to #{user.container_limit}/
        end
      end
    end
  end
end
