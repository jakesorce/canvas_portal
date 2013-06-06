require 'active_record'

module Connection
  def open
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: File.expand_path(File.dirname(__FILE__) + '/../../portal.db')
    )
    ActiveRecord::Base.connection
  end

  def close(connection)
    connection.disconnect!
  end
  module_function :open
  module_function :close
end
