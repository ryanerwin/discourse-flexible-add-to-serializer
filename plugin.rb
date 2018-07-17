# name: custom-attributes
# version: 0.1
# author: Muhlis Budi Cahyono (muhlisbc@gmail.com)
# url: https://github.com/ryanerwin/discourse-flexible-add-to-serializer

enabled_site_setting :custom_attributes_enabled

after_initialize {

  # custom attributes
  add_to_serializer(:post, :user_info) {
    user_id = object.user_id

    if user_id.present?
      User.get_user_info(user_id)
    end
  }

  add_to_serializer(:topic_list_item, :last_poster_name) {
    User.get_cached_name(object.last_post_user_id)
  }

  add_to_serializer(:basic_user, :name) {
    @user_name ||= User.get_cached_name(id)
  }

  add_to_serializer(:notification, :data) {
    data_hash = object.data_hash

    %w(display_username username2).each do |k|
      if uname = data_hash[k]
        name = User.get_cached_name2(uname)
        data_hash[k] =  name if !name.blank?
      end
    end

    data_hash
  }

  # model callbacks (cache invalidation)
  require_dependency "user_stat"
  UserStat.class_eval {

    after_save {
      if self.saved_change_to_post_count?
        User.set_user_info(self.user_id)
      end
    }

  }

  require_dependency "user_profile"
  UserProfile.class_eval {

    after_save {
      if self.saved_change_to_location?
        User.set_user_info(self.user_id)
      end
    }

  }

  require_dependency "user"
  User.class_eval {

    after_save {
      if self.saved_change_to_name?
        User.set_cached_name(self.id, self.name)
        User.set_cached_name2(self.username, self.name)
      end

      if self.saved_change_to_username?
        User.set_cached_name2(self.username, self.name)
      end
    }

    # class methods
    def self.get_cached_name(user_id)
      $redis.get("name_#{user_id}") || set_cached_name(user_id)
    end

    def self.set_cached_name(user_id, name = nil)
      name ||= (User.where(id: user_id).first&.name || "")
      $redis.set("name_#{user_id}", name)
      name
    end

    def self.get_cached_name2(username)
      $redis.get("name_u_#{username}") || set_cached_name2(username)
    end

    def self.set_cached_name2(username, name = nil)
      name ||= (User.where(username: username).first&.name || "")
      $redis.set("name_u_#{username}", name)
      name
    end

    def self.get_user_info(user_id)
      if user_info = $redis.get("user_info_#{user_id}")
        JSON.parse(user_info)
      else
        set_user_info(user_id)
      end
      
    end

    def self.set_user_info(user_id)
      user = User.where(id: user_id).first

      obj = user ? { location: user.user_profile.location, created_at: user.created_at, post_count: user.user_stat&.post_count } : {}

      $redis.set("user_info_#{user_id}", obj.to_json)

      obj
    end

  }

}
