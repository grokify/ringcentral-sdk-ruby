module RingCentralSdk::REST
  class ExtensionPresence
    attr_accessor :client
    attr_accessor :account_id
    attr_accessor :extension_id
    attr_accessor :presence_data

    def initialize(extension_id, opts = {})
      @client = opts.key?(:client) ? opts[:client] : nil
      @account_id = '~'
      @extension_id = extension_id.to_s
      @presence_data = {}
    end

    def retrieve()
      if @extension_id !~ /^[0-9]+$/
        raise "extension_id is not an integer"
      end

      res = @client.http.get do |req|
        req.url "account/#{@account_id}/extension/#{@extension_id}/presence"
      end

      @presence_data = res.body

      return @presence_data
    end

    def department_calls_enable(enable)
      retrieve()

      unless @presence.is_a?(Hash) && @presence_data.key?('dndStatus')
        raise 'invalid presence info'
      end

      current_status = @presence_data['dndStatus']
      new_status = new_status_dnd_department_calls(current_status, enable)

      if current_status != new_status
        update({ dndStatus: new_status })
      end

      return new_status
    end

    def department_calls_enabled?(reload = false)
      if reload
        retrieve()
      elsif !@presence_data.key?('dndStatus')
        retrieve()
      end

      current_status = @presence_data['dndStatus']

      status_enabled = {
        'DoNotAcceptAnyCalls' => false,
        'DoNotAcceptDepartmentCalls' => false,
        'TakeAllCalls' => true,
        'TakeDepartmentCallsOnly' => true
      }

      return status_enabled.key?(current_status) ?
        status_enabled[current_status] : nil
    end

    def update(body = nil)
      if body.nil?
        raise 'HTTP request body is required to update presence'
      end

      res = @client.http.put do |req|
        req.url "account/#{@account_id}/extension/#{@extension_id}/presence"
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end

      @presence_data = res.body

      return @presence_data
    end

    def new_status_dnd_department_calls(current_status, enable)
      new_statuses = {
        enable: {
          'DoNotAcceptAnyCalls' => 'TakeDepartmentCallsOnly',
          'DoNotAcceptDepartmentCalls' => 'TakeAllCalls'
        },
        disable: {
          'TakeAllCalls' => 'DoNotAcceptDepartmentCalls',
          'TakeDepartmentCallsOnly' => 'DoNotAcceptAnyCalls'
        }
      }

      action = enable ? :enable : :disable

      new_status = current_status

      new_status = new_statuses[action][current_status.to_s] \
        if new_statuses[action].key?(current_status.to_s)

      return new_status
    end
  end
end