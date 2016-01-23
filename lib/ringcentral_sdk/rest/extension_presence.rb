module RingCentralSdk
  class ExtensionPresence

    attr_accessor :client
    attr_accessor :account_id
    attr_accessor :extension_id
    attr_accessor :presence_data

    def initialize(extension_id, opts={})
      @client = opts.has_key?(:client) ? opts[:client] : nil
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

      if !@presence_data.has_key?('dndStatus')
        raise 'invalid presence info'
      end

      current_status = @presence_data['dndStatus']
      new_status = enable ?
        status_enable_dnd_department_calls(current_status) :
        status_disable_dnd_department_calls(current_status)

      if current_status != new_status
        update({:dndStatus => new_status})
      end
    end

    def department_calls_enabled?(reload=false)
      if reload
        retrieve()
      elsif !@presence_data.has_key?('dndStatus')
        retrieve()
      end

      current_status = @presence_data['dndStatus']

      status_enabled = {
        'DoNotAcceptAnyCalls' => false,
        'DoNotAcceptDepartmentCalls' => false,
        'TakeAllCalls' => true,
        'TakeDepartmentCallsOnly' => true
      }

      return status_enabled.has_key?(current_status) ?
        status_enabled[current_status] : nil
    end

    def disable_department_calls()
      retrieve()

      if !@presence_data.has_key?('dndStatus')
        raise 'invalid presence info'
      end

      current_status = @presence_data['dndStatus']
      new_status = status_disable_dnd_department_calls(current_status)

      if current_status != new_status
        update({:dndStatus => new_status})
      end
    end

    def update(body=nil)
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

    def status_enable_dnd_department_calls(current_status)
      new_status = current_status

      new_statuses = {
        'DoNotAcceptAnyCalls' => 'TakeDepartmentCallsOnly',
        'DoNotAcceptDepartmentCalls' => 'TakeAllCalls'
      }

      if new_statuses.has_key?(current_status.to_s)
        new_status = new_statuses[current_status.to_s]
      end

      return new_status
    end

    def status_disable_dnd_department_calls(current_status)
      new_status = current_status

      new_statuses = {
        'TakeAllCalls' => 'DoNotAcceptDepartmentCalls',
        'TakeDepartmentCallsOnly' => 'DoNotAcceptAnyCalls'
      }

      if new_statuses.has_key?(current_status.to_s)
        new_status = new_statuses[current_status.to_s]
      end

      return new_status
    end

  end
end