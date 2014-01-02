//
//  SAMWeak.h
//
//  Created by Roman Kříž on 07.08.13.
//  Copyright (c) 2013 samnung. All rights reserved.
//

#ifndef SAM_WEAK
#define SAM_WEAK

#ifndef SAM_WEAK_NAME
	#define SAM_WEAK_NAME(name) _##name
#endif

#ifndef SAM_STRONG_NAME
	#define SAM_STRONG_NAME(name) s##name
#endif

/**
 * Creates weak reference to object. Default new name is _(__self)
 *
 * @note If you want to change the patern name define macro SAM_WEAK_NAME().
 * Something like #define SAM_WEAK_NAME(name) _##name
 */
#define WEAK(__self) __weak __typeof(__self) SAM_WEAK_NAME(__self) = __self

/**
 * Creates strong reference to object. Default new name is s(__self)
 *
 * @note If you want to change the patern name define macro SAM_STRONG_NAME().
 * Something like #define SAM_STRONG_NAME(name) s##name
 */
#define STRONG(__self) __strong __typeof(__self) SAM_STRONG_NAME(__self) = __self

#endif
