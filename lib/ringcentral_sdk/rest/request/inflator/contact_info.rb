module RingCentralSdk
  module REST
    module Request
      module Inflator
        # ContactInfo class will inflate contact info to array
        class ContactInfo
          def inflate_to_array(any = nil)
            contacts = []
            if any.is_a?(Array)
              any.each do |contact|
                contacts.push inflate_to_object(contact)
              end
            elsif any.is_a?(Hash)
              contacts = [any]
            elsif any.is_a?(String) || any.is_a?(Integer)
              contacts = [{ phoneNumber: any }]
            end
            contacts
          end

          def inflate_to_object(any = nil)
            contact = {}
            if any.is_a?(Hash)
              contact = any
            elsif any.is_a?(String) || any.is_a?(Integer)
              contact = { phoneNumber: any }
            end
            contact
          end
        end
      end
    end
  end
end
