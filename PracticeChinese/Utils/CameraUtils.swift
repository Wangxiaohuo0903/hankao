//
//  CameraUtils.swift
//  ChineseLearning
//
//  Created by feiyue on 05/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//
/*
import Foundation
import MobileCoreServices
import UIKit

class Camera {
    
    class func shouldStartCamera(_ target: AnyObject, canEdit: Bool, frontFacing: Bool) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == false {
            return false
        }
        
        let type = kUTTypeImage as String
        let cameraUI = UIImagePickerController()
        
        let available = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera) as [String]!).contains(type)
        
        if available {
            cameraUI.mediaTypes = [type]
            cameraUI.sourceType = UIImagePickerControllerSourceType.camera
            
            /* Prioritize front or rear camera */
            if (frontFacing == true) {
                if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.front
                } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.rear
                }
            } else {
                if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.rear) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.rear
                } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.front) {
                    cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.front
                }
            }
        } else {
            return false
        }
        //cameraUI.delegate = target as! EditProfileViewController
        cameraUI.allowsEditing = canEdit
        cameraUI.showsCameraControls = true
        
        target.present(cameraUI, animated: true, completion: nil)
        
        return true
    }
    
    class func shouldStartPhotoLibrary(_ target: AnyObject, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            return false
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary) as [String]!).contains(type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.savedPhotosAlbum) as [String]!).contains(type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        }
        else {
            return false
        }
        //imagePicker.delegate = target as! EditProfileViewController
        imagePicker.allowsEditing = canEdit
        
        target.present(imagePicker, animated: true, completion: nil)
        
        return true
    }
    
    class func shouldStartVideoLibrary(_ target: AnyObject, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            return false
        }
        
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary) as [String]!).contains(type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) && (UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.savedPhotosAlbum) as [String]!).contains(type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        }
        else {
            return false
        }
        //imagePicker.delegate = target as! EditProfileViewController
        imagePicker.allowsEditing = canEdit
        target.present(imagePicker, animated: true, completion: nil)
        
        return true
    }
}*/
