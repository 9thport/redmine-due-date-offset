module RedmineDueDateByDefault
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          
          # run code for updating issue
          alias_method_chain :update, :write_due_date
          
          # run code for creating new issue (aka writing issue to database)
          alias_method_chain :create, :write_due_date
          
          # run code for making new issue
          alias_method_chain :new, :write_fixed_version
        end
      end

      module ClassMethods
      end

      module InstanceMethods        
        def update_with_write_due_date
          issue = Issue.find(params[:id])
                    
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            if ! params[:issue][:start_date].nil? || (params[:issue][:start_date] == '')
              params[:issue][:due_date] = next_weekday(params[:issue][:start_date], 3).strftime("%m/%d/%Y").to_s
            else
              params[:issue][:start_date] = Time.now.strftime("%m/%d/Y").to_s
              params[:issue][:due_date] = next_weekday(params[:issue][:start_date], 3).strftime("%m/%d/%Y").to_s
            end            
          end
                    
          update_without_write_due_date              
        end

        def new_with_write_fixed_version
          # project = Project.find(params[:project_id]) 
          # field = project.custom_field_values.find {|field| field.custom_field_id == 21}
          # if !field.nil?
          #   params[:issue] = {} if params[:issue].nil?
          #   build_new_issue_from_params
          # end
          # new_without_write_fixed_version
        end

        def create_with_write_due_date
          
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            if ! params[:issue][:start_date].nil? || (params[:issue][:start_date] == '')
              params[:issue][:due_date] = next_weekday(params[:issue][:start_date], 3).strftime("%m/%d/%Y").to_s
            # else
            #   params[:issue][:start_date] = Time.now.strftime("%m/%d/Y").to_s
            #   params[:issue][:due_date] = next_weekday(params[:issue][:start_date], 3).strftime("%m/%d/%Y").to_s
            end            
          end

          build_new_issue_from_params
          create_without_write_due_date
        end
        
        def parsed_date(date)
          year,month,day = date.to_s.split("-")
          
          org_date = Time.new(year,month,day,00,00,00, "-08:00")
          return org_date
        end
        
        def next_weekday(original_date, step=1)    
          result = parsed_date(original_date)
          counter = 0

          until counter == step
            result += 1.day
            counter += 1

            if result.saturday?
              result += 1.day
            end

            if result.sunday?
              result += 1.day
            end
          end
          result
        end
        
      end
    end
  end
end
