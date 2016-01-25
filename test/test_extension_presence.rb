require './test/test_base.rb'

class RingCentralSdkRESTExtensionPresenceTest < Test::Unit::TestCase
  def setup
    @rcsdk = RingCentralSdk.new(
      'my_app_key',
      'my_app_secret',
      RingCentralSdk::RC_SERVER_SANDBOX
    )
  end

  def test_department_calls_enable

    presence = RingCentralSdk::REST::ExtensionPresence.new(111111)

    new_statuses = {
      :enable => {
        'DoNotAcceptAnyCalls' => 'TakeDepartmentCallsOnly',
        'DoNotAcceptDepartmentCalls' => 'TakeAllCalls'
      },
      :disable => {
        'TakeAllCalls' => 'DoNotAcceptDepartmentCalls',
        'TakeDepartmentCallsOnly' => 'DoNotAcceptAnyCalls'
      }
    }

    cur_status = 'TakeAllCalls'
    assert_equal 'DoNotAcceptDepartmentCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal 'TakeAllCalls', \
      presence.new_status_dnd_department_calls(cur_status, true)

    cur_status = 'TakeDepartmentCallsOnly'
    assert_equal 'DoNotAcceptAnyCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal 'TakeDepartmentCallsOnly', \
      presence.new_status_dnd_department_calls(cur_status, true)

    cur_status = 'DoNotAcceptAnyCalls'
    assert_equal 'DoNotAcceptAnyCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal 'TakeDepartmentCallsOnly', \
      presence.new_status_dnd_department_calls(cur_status, true)

    cur_status = 'DoNotAcceptDepartmentCalls'
    assert_equal 'DoNotAcceptDepartmentCalls', \
      presence.new_status_dnd_department_calls(cur_status, false)
    assert_equal 'TakeAllCalls', \
      presence.new_status_dnd_department_calls(cur_status, true)

  end
end