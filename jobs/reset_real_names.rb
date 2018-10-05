module Jobs
  class ResetRealNames < Jobs::Onceoff

    def execute_onceoff(args)
      $redis.delete_prefixed("name_u_")
    end

  end
end
