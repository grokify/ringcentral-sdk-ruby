module RingCentralSdk
  module REST
    module Request
      module Inflator
        # ContactInfo class will inflate contact info to array
        class ContactInfo
          def inflate_to_array(any = nil)
            contacts   = []
            if any.is_a?(Array)
              contacts = any
            elsif any.is_a?(Hash)
              contacts = [any]
            elsif any.is_a?(String) || any.is_a?(Integer)
              contacts = [{ phoneNumber: any }]
            end
            contacts
          end
        end
      end
    end
  end
end
