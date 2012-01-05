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
        # when updating an issues due_date     
        def update_with_write_due_date
          issue = Issue.find(params[:id])
                    
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            if ! params[:issue][:start_date].nil? || (params[:issue][:start_date] == '')
              year, month, day = params[:issue][:start_date].split('-')
              new_date = Time.local(year,month,day)
              
              params[:issue][:due_date] = next_weekday(new_date, 3).strftime("%m/%d/%Y").to_s
            else
              params[:issue][:start_date] = Time.now.strftime("%m/%d/Y").to_s
              params[:issue][:due_date] = next_weekday(Time.now, 3).strftime("%m/%d/%Y").to_s
            end            
          end
                    
          update_without_write_due_date              
        end
        
        # when making a new issue (this is also used when changing trackers)
        def new_with_write_fixed_version
          project = Project.find(params[:project_id]) 
          field = project.custom_field_values.find {|field| field.custom_field_id == 21}
          if !field.nil?
            params[:issue] = {} if params[:issue].nil?
            build_new_issue_from_params
          end
          new_without_write_fixed_version
        end

        # when creating a new issue and setting a due date
        def create_with_write_due_date
          
          if params[:issue][:due_date].nil? || (params[:issue][:due_date] == '')
            if !params[:issue][:start_date] == ""
            # if ! params[:issue][:start_date].nil? || (params[:issue][:start_date] == "")
              year, month, day = params[:issue][:start_date].split('-')
              new_date = Time.local(year,month,day)
              
              params[:issue][:due_date] = next_weekday(new_date, 3).strftime("%m/%d/%Y").to_s
            # else
            #   params[:issue][:start_date] = Time.now.strftime("%m/%d/Y").to_s
            #   params[:issue][:due_date] = next_weekday(params[:issue][:start_date], 3).strftime("%m/%d/%Y").to_s
            end            
          end

          build_new_issue_from_params
          create_without_write_due_date
        end
                
        # calculate the next weekday (e.g. skip the weekends)
        def next_weekday(original_date, step=1)  
          result = original_date
          counter = 0

          until counter == step
            result += 1.day
            counter += 1

            # if day is saturday, add one more day
            if result.wday == 6
              result += 1.day
            end

            # if day is sunday, add one more day
            if result.wday == 0
              result += 1.day
            end
          end
          
          # return date
          result
        end
        
      end
    end
  end
end
