UppServer::Application.routes.draw do
  api version: 1..2 do
    resources :users, except: [:new, :edit]
    resources :forms, except: [:new, :edit] do
      resources :stop_reasons, except: [:new, :edit]
      resources :sections, except: [:new, :edit] do
        resources :fields, except: [:new, :edit]
      end

      resources :assignments, except: [:new, :edit, :show]
    end

    resources :submissions, except: [:new, :edit]
    resources :texts, except: [:new, :edit]

    get '/users/:user_id/submissions' => 'users#submissions'
    get '/forms/:form_id/users/:user_id/submissions' => 'users#submissions'
    get '/users/:user_id/forms' => 'users#forms'

    match '/application' => 'static#save_config', via: [:put, :post]
    get '/application' => 'static#show_config'

    get '/forms/:form_id/submissions' => 'submissions#index'
    post '/forms/:form_id/submissions' => 'submissions#create'
    get '/forms/:form_id/submissions/:id' => 'submissions#show'
    post '/forms/:form_id/submissions/:id/reset' => 'submissions#reset'
    put '/forms/:form_id/submissions/:id' => 'submissions#update'
    post '/forms/:form_id/submissions/:submission_id/corrections' => 'submissions#create_correction'
    put '/forms/:form_id/submissions/:submission_id/corrections/:id' => 'submissions#update_correction'
    delete '/forms/:form_id/submissions/:id/corrections/:id' => 'submissions#delete_correction'
    post '/forms/:form_id/submissions/:id/reschedule' => 'submissions#reschedule'
    post '/forms/:form_id/submissions/:id/moderate' => 'submissions#moderate'

    post '/submissions/swap' => 'submissions#swap'
    post '/submissions/transfer' => 'submissions#transfer_by_submission_id'
    post '/forms/:form_id/submissions/transfer' => 'submissions#transfer_by_form_id'

    get '/users/:id/users' => 'users#users'

    get '/forms/:form_id/users/:user_id/statistics' => 'statistics#user'
    get '/forms/:form_id/statistics' => 'statistics#form'
    get '/users/:user_id/statistics' => 'statistics#user'
    get '/statistics' => 'statistics#global'

    get '/users/:user_id/logs' => 'logs#index'

    put '/forms' => 'forms#update_order'
    put '/forms/:form_id/sections' => 'sections#update_order'
    put '/forms/:form_id/fields' => 'fields#update_order'
    put '/forms/:form_id/sections/:section_id/fields' => 'fields#update_order'

    post '/forms/:form_id/parse_csv' => 'import#parse'
    post '/forms/:id/copy' => 'forms#copy'
    post '/forms/:form_id/import_csv/:job_id' => 'import#import'

    post '/users/:id/avatar' => 'users#save_avatar'
    delete '/users/:id/avatar' => 'users#remove_avatar'

    post '/session' => 'auth#login'
    delete '/session' => 'auth#logout'

    get '/logs' => 'logs#index'

    post '/users/export/csv' => 'export#users'
    post '/forms/export/csv' => 'export#forms'
    post '/fields/export/csv' => 'export#fields'
    post '/forms/:form_id/submissions/export/csv' => 'export#submissions'
    post '/forms/:form_id/submissions/answers/export/csv' => 'export#answers'
    get '/export/progress(/:job_id)' => 'export#progress'
    get '/exports' => 'export#exports'
  end

  match '(*path)' => 'application#options', via: :options
end
