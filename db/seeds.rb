User.create!(username: 'apiuser',   password: 'apipass',   password_confirmation: 'apipass',   name: 'API Guy', role: 'api')
puts 'created user API | user: apiuser, pass: apipass'
User.create!(username: 'moduser',   password: 'modpass',   password_confirmation: 'modpass',   name: 'MOD Guy', role: 'mod')
puts 'created user MOD | user: moduser, pass: modpass'
User.create!(username: 'agentuser', password: 'agentpass', password_confirmation: 'agentpass', name: 'Guy Guy', role: 'agent')
puts 'created user AGENT | user: agentuser, pass: agentpass'

sample_form = Form.create!(name: "Formulario de teste #{Time.now.to_i}", subtitle: 'Pode excluir-me')
section = sample_form.sections.create!(name: 'Perguntas')
section.fields << TextField.create!(label: 'Campo de texto obrigatório', description: 'Muito obrigatório', identifier: true)
section.fields << NumberField.create!(label: 'Qual desses é acima de 9000?', required: true, range: [9000, 9001])
section.fields << EmailField.create!(label: 'Seu email')
section.fields << PrivateField.create!(label: 'Após perde foco este campo irá ficar bloqueado')
section.fields << DatetimeField.create!(label: 'Quando você nasceu?')
section.fields << UrlField.create!(label: 'Uma URL')
section.fields << RadioField.create!(label: 'Algumas opçnoes', options: [{label: 'Sim', value: 'of_course'},
                                                                    {label: 'Nai', value: 'yoshi'}])
section.save!

puts "created Form #{sample_form.name}"
