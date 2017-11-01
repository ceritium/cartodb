module CartoDB
  module UserTokenDecorator
    attr_accessor :user_token

    def token_table
      if user_token
        user_token.user_table
      end
    end

    def can_read_table?(user_table)
      token_table == user_table
    end

    def can_write_table?(user_table)
      can_read_table?(user_table) && user_token.writable?
    end
  end
end
