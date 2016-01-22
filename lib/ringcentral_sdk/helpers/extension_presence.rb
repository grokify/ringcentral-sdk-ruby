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

      if res.status != 200
        raise 'Cannot retrieve extension presence info'
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
        update_presence({:dndStatus => new_status})
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
        update_presence({:dndStatus => new_status})
      end
    end

    def update_presence(body=nil)
      if body.nil?
      	raise 'cannot update presence with no body'
      end
      res = @rc_api.client.put do |req|
        req.url "account/#{@account_id}/extension/#{@extension_id}/presence"
        req.headers['Content-Type'] = 'application/json'
        req.body = body
      end
      @presence_info = res.body
      return res
    end

    def status_enable_dnd_department_calls(current_status)
      new_status = current_status
      if current_status.to_s == 'DoNotAcceptAnyCalls'
      	new_status = 'TakeDepartmentCallsOnly'
      elsif current_status.to_s == 'DoNotAcceptDepartmentCalls'
      	new_status = 'TakeAllCalls'
      end
      return new_status
    end

    def status_disable_dnd_department_calls(current_status)
      new_status = current_status
      if current_status.to_s == 'TakeAllCalls'
      	new_status = 'DoNotAcceptDepartmentCalls'
      elsif current_status.to_s == 'TakeDepartmentCallsOnly'
      	new_status = 'DoNotAcceptAnyCalls'
      end
      return new_status
    end

  end
end