module RingCentralSdk::Helpers
  class ExtensionPresence

    attr_accessor :rc_api
    attr_accessor :account_id
    attr_accessor :exension_id
    attr_accessor :presence_info

    def initialize(rc_api, extension_id=nil)
      @rc_api = rc_api
      @account_id = '~'
      @extension_id = extension_id.to_s
      @presence_info = {}
    end

    def retrieve()
      if @extension_id !~ /^[0-9]+$/
        raise "extension_id is not an integer"
      end

      res = @rc_api.client.get do |req|
        req.url "account/#{@account_id}/extension/#{@extension_id}/presence"
      end

      @presence_info = res.body

      return @presence_info
    end

    def enable_dnd_department_calls()
      retrieve()

      if !@presence_info.has_key?('dndStatus')
        raise 'invalid presence info'
      end

      current_status = @presence_info['dndStatus']
      new_status = status_enable_dnd_department_calls(current_status)

      if current_status != new_status
        update({:dndStatus => new_status})
      end
    end

    def disable_dnd_department_calls()
      retrieve()

      if !@presence_info.has_key?('dndStatus')
        raise 'invalid presence info'
      end

      current_status = @presence_info['dndStatus']
      new_status = status_disable_dnd_department_calls(current_status)

      if current_status != new_status
        update({:dndStatus => new_status})
      end
    end

    def update(body=nil)
      if body.nil?
        raise 'HTTP request body is required to update presence'
      end

      res = @rc_api.client.put do |req|
        req.url "account/#{@account_id}/extension/#{@extension_id}/presence"
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end
      
      @presence_info = res.body

      return @presence_info
    end

    def status_enable_department_calls(current_status)
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

    def status_disable_department_calls(current_status)
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