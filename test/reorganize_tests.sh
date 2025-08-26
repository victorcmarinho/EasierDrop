#!/bin/bash

# Diretório base para testes
TEST_DIR="/Users/victormarinho/Documents/easier_drop/test"
cd "$TEST_DIR"

# Mover testes para as pastas correspondentes
echo "Movendo arquivos de teste para suas respectivas pastas..."

# Components
# - Hover Icon Button
mv hover_icon_button_test.dart components/
mv hover_icon_button_more_test.dart components/
mv hover_icon_button_extra_test.dart components/
mv hover_icon_button_advanced_test.dart components/
mv hover_icon_button_disabled_test.dart components/

# - Mac Close Button
mv mac_close_button_test.dart components/
mv mac_close_button_more_test.dart components/
mv mac_close_button_extra_test.dart components/
mv mac_close_button_animation_test.dart components/
mv mac_close_button_states_test.dart components/

# - Share and Remove Buttons
mv share_remove_buttons_test.dart components/

# - Files Stack
mv files_stack_more_test.dart components/

# - Components Parts
mv file_actions_bar_test.dart components/parts/
mv file_actions_bar_alt_test.dart components/parts/
mv file_actions_bar_new_test.dart components/parts/
mv file_actions_bar_simplified_test.dart components/parts/
mv files_surface_test.dart components/parts/
mv files_surface_complete_test.dart components/parts/
mv marquee_text_no_overflow_function_test.dart components/parts/

# Controllers
mv drag_coordinator_test.dart controllers/
mv drag_coordinator_dispose_test.dart controllers/
mv drag_coordinator_error_test.dart controllers/

# Helpers
mv file_icon_helper_test.dart helpers/macos/

# L10n
mv i18n_test.dart l10n/
mv arb_parity_test.dart l10n/

# Model
mv file_reference_test.dart model/
mv file_reference_more_test.dart model/
mv file_reference_error_paths_test.dart model/

# Providers
mv files_provider_test.dart providers/
mv files_provider_more_test.dart providers/
mv files_provider_additional_test.dart providers/
mv files_provider_icon_test.dart providers/
mv files_provider_limit_test.dart providers/
mv files_provider_share_test.dart providers/
mv files_provider_share_message_test.dart providers/

# Services
mv drag_result_test.dart services/
mv drag_result_additional_test.dart services/
mv drag_result_error_test.dart services/
mv drag_result_exception_test.dart services/
mv drag_result_complete_test.dart services/
mv services_additional_test.dart services/
mv services_channel_test.dart services/
mv settings_and_drag_out_test.dart services/
mv settings_service_edges_test.dart services/
mv logger_levels_test.dart services/

# Outros (manter na raiz)
# ui_semantics_test.dart - é um teste geral de semântica da UI
# exclusion_marker.dart - é um arquivo auxiliar, não um teste

echo "Reorganização concluída!"
