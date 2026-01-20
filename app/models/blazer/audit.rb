module Blazer
  class Audit < Record
    belongs_to :user, optional: true, class_name: Blazer.user_class.to_s if Blazer.user_class
    belongs_to :query, optional: true
  end
end
