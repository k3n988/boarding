# Final Boarding – Updated Folder Structure

Generated from the current `lib/` and project layout.

```
finalboarding/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── firebase_options.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_sizes.dart
│   │   ├── errors/
│   │   │   └── failure.dart
│   │   ├── network/
│   │   │   └── api_client.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── services/
│   │   │   ├── location_service.dart
│   │   │   └── notification_service.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── custom_text_field.dart
│   │       └── loading_indicator.dart
│   │
│   └── features/
│       ├── account/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── profile_model.dart
│       │   │   └── repositories/
│       │   │       ├── profile_repository.dart
│       │   │       └── profile_repository_impl.dart
│       │   ├── viewmodels/
│       │   │   └── account_viewmodel.dart
│       │   └── views/
│       │       ├── account_screen.dart
│       │       └── widgets/
│       │           ├── account_list_tile.dart
│       │           └── profile_avatar.dart
│       │
│       ├── auth/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── user_model.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository.dart
│       │   ├── viewmodels/
│       │   │   └── auth_viewmodel.dart
│       │   └── views/
│       │       ├── auth_gate.dart
│       │       ├── login_screen.dart
│       │       ├── register_screen.dart
│       │       └── widgets/
│       │           └── auth_form_field.dart
│       │
│       ├── bookings/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── booking_model.dart
│       │   │   │   └── payment_model.dart
│       │   │   └── repositories/
│       │   │       └── booking_repository.dart
│       │   ├── viewmodels/
│       │   │   └── booking_viewmodel.dart
│       │   └── views/
│       │       ├── booking_screen.dart
│       │       └── widgets/
│       │           ├── booking_summary_card.dart
│       │           └── payment_method_selector.dart
│       │
│       ├── landlord/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── host_model.dart
│       │   │   └── repositories/
│       │   │       └── landlord_repository.dart
│       │   ├── viewmodels/
│       │   │   └── landlord_viewmodel.dart
│       │   └── views/
│       │       ├── landlord_dashboard_screen.dart
│       │       └── widgets/
│       │           └── host_profile_card.dart
│       │
│       ├── map/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── map_marker_model.dart
│       │   │   └── repositories/
│       │   │       └── map_repository.dart
│       │   ├── viewmodels/
│       │   │   └── map_viewmodel.dart
│       │   └── views/
│       │       ├── map_screen.dart
│       │       └── widgets/
│       │           ├── map_filter_bar.dart
│       │           └── safety_heatmap_layer.dart
│       │
│       ├── properties/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── property_model.dart
│       │   │   │   ├── room_model.dart
│       │   │   │   └── amenity_model.dart
│       │   │   ├── mock_properties.dart
│       │   │   └── repositories/
│       │   │       └── property_repository.dart
│       │   ├── viewmodels/
│       │   │   ├── home_viewmodel.dart
│       │   │   └── property_detail_viewmodel.dart
│       │   └── views/
│       │       ├── home_screen.dart
│       │       ├── filter_screen.dart
│       │       ├── property_detail_screen.dart
│       │       ├── property_details_host_screen.dart
│       │       ├── post_property/                    # Post tab (4 files)
│       │       │   ├── post_screen.dart              # Entry: PostScreen
│       │       │   ├── verification_step.dart       # KYC + IdentityVerificationFlow
│       │       │   ├── posting_form.dart             # PostingForm (create listing)
│       │       │   └── pin_location_screen.dart      # PinLocationScreen
│       │       └── widgets/
│       │           ├── ai_banner.dart
│       │           ├── filter_dropdown.dart
│       │           ├── property_card.dart
│       │           ├── room_filter_sheet.dart
│       │           └── property_type_tabs/
│       │               ├── apartment_tab.dart
│       │               ├── bedspace_tab.dart
│       │               ├── boardinghouse_tab.dart
│       │               └── dorm_tab.dart
│       │
│       └── saved/
│           ├── data/
│           │   ├── models/
│           │   │   └── saved_item_model.dart
│           │   └── repositories/
│           │       ├── saved_repository.dart
│           │       └── saved_repository_impl.dart
│           ├── viewmodels/
│           │   └── saved_viewmodel.dart
│           └── views/
│               ├── saved_screen.dart
│               └── widgets/
│                   ├── saved_list.dart
│                   └── saved_property_card.dart
│
├── test/
│   └── widget_test.dart
│
├── pubspec.yaml
└── (android/, ios/, web/, windows/, macos/ as per Flutter project)
```

## Summary

- **Root:** `main.dart`, `app.dart`, `firebase_options.dart`
- **core/** – Shared: constants, errors, network, router, services, theme, widgets
- **features/** – One folder per feature:
  - **account** – Profile, settings, list tiles
  - **auth** – Login, register, auth gate, form field
  - **bookings** – Booking/payment models, repository, viewmodel, screen, summary card, payment selector
  - **landlord** – Host model, landlord repo/viewmodel, dashboard, host profile card
  - **map** – Map marker, map repo/viewmodel, map screen, filter bar, heatmap layer
  - **properties** – Property/room/amenity models, mock data, repo, home/detail viewmodels, home/filter/detail/post screens, **post_property/** (post_screen, verification_step, posting_form, pin_location_screen), and shared widgets (e.g. property_card, room_filter_sheet, property_type_tabs)
  - **saved** – Saved item model, saved repo (impl), saved viewmodel, saved screen, saved list/card widgets
