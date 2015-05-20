module RingCentralSdk::Helpers::Inflator
  class ContactInfo
    def inflate_to_array(any=nil)
      contacts   = []
      if any.is_a?(Array)
        contacts = any
      elsif any.is_a?(Hash)
        contacts = [any]
      elsif any.is_a?(String) || any.is_a?(Integer)
        contacts = [{:phoneNumber=>any}]
      end
      return contacts
    end
  end
end