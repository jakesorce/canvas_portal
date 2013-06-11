require 'active_record'
module Connection
  def manage_connection(&block)
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: File.expand_path(File.dirname(__FILE__) + '/../../portal.db')
    )
    ActiveRecord::Base.connection
    block.call
    ActiveRecord::Base.connection.close
  end

  module_function :manage_connection
end
