require "test_helper"

class ClientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @client = clients(:one)
    sign_in @user  # Authentification avec Devise
  end

  test "should get index" do
    get clients_url
    assert_response :success
    # Vérifie que seuls les clients de l'utilisateur connecté sont affichés
    assert_select "table tbody tr", count: 2  # user(:one) a 2 clients (one et two)
  end

  test "should get new" do
    get new_client_url
    assert_response :success
  end

  test "should create client" do
    assert_difference("Client.count") do
      post clients_url, params: { 
        client: { 
          nom: "Nouveau",
          prenom: "Client",
          description: "Description test",
          date_debut: Date.today,
          date_fin: Date.today + 1.year,
          user_id: @user.id
        } 
      }
    end

    assert_redirected_to clients_url
  end

  test "should not create client without nom" do
    assert_no_difference("Client.count") do
      post clients_url, params: { 
        client: { 
          prenom: "Client",
          description: "Description test",
          date_debut: Date.today,
          date_fin: Date.today + 1.year,
          user_id: @user.id
        } 
      }
    end
  end

  test "should show client" do
    get client_url(@client)
    assert_response :success
    assert_select "h1", text: "Détails du Client"
  end

  test "should get edit" do
    get edit_client_url(@client)
    assert_response :success
  end

  test "should update client" do
    patch client_url(@client), params: { 
      client: { 
        nom: "Nom Modifié",
        prenom: @client.prenom,
        description: @client.description,
        date_debut: @client.date_debut,
        date_fin: @client.date_fin
      } 
    }
    assert_redirected_to clients_url
    
    # Vérifie que le nom a été mis en majuscules (logique du contrôleur)
    @client.reload
    assert_equal "NOM MODIFIÉ", @client.nom
  end

  test "should destroy client" do
    assert_difference("Client.count", -1) do
      delete client_url(@client)
    end

    assert_redirected_to clients_url
  end

  test "should redirect to login if not authenticated" do
    sign_out @user
    get clients_url
    assert_redirected_to new_user_session_url
  end
end
